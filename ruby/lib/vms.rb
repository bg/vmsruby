# Because vms.rb is included in everything, be very careful about requiring
# things that need the following VMS ruby tweaks to be applied first.

require 'aspect'

case RUBY_PLATFORM
    when /VMS/i

        alias :__original_vms_exit__ :exit

        VMS_SYSTEM_F_ABORT=44 # See "HELP/MESSAGE/STATUS=44", consistent with Perl usage
        
        def vms_exit exit_code=0
            __original_vms_exit__([1,-1].member?(exit_code) ? VMS_SYSTEM_F_ABORT : exit_code)
        end

        alias :exit :vms_exit
        
        # Define missing class_variable_set/get methods
        class Module
            unless defined? class_variable_get
                def class_variable_get name
                    return class_eval("#{name}")
                end
            end
            unless defined? class_variable_set
                def class_variable_set name, value
                    class_eval "#{name}=value"
                end
            end
        end

        module Marshal
            class << self

                alias :old_dump :dump

                # binmode not sufficient to write binaray data without corruption
                # FIXME: should be fixed in Ruby IO.C
                def dump *args
                    args[1].write_mode=:FWRITE if IO===args[1]
                    old_dump(*args)
                end
            end
        end
        
        module VMS
            class SystemInfo
                @@vms_version=nil
                def self.vms_version
                    if @@vms_version
                        @@vms_version
                    else
                        version=`write sys$output f$getsyi("node_swvers")`.chomp
                        major,minor=version.sub!(/^V/,'').split('.')
                        @@vms_version=major.to_i*100+minor.to_i
                    end
                end
            end
        end

        class File

            FWRITE_SENSITIVE_METHODS=[:write]

            attr_accessor :write_mode

            class << self
                alias old_expand_path expand_path
            end

            # We standardize on Unix-style paths as being 'canonical'.  Thus,
            # expand_path should produce one.
            def self.expand_path file_name,dir_string=nil
                file_name=vms_to_unix_path file_name
                dir_string=dir_string ? vms_to_unix_path(dir_string) : vms_to_unix_path(Dir.old_pwd)
                file_name=old_expand_path(file_name,dir_string)
                file_name
            end

            def self.vms_to_unix_path path
        		path.sub!(/^\[/,'sys$disk:[')
                path.sub!(/^(.*?)\:/,'/\1/')
                # FIXME: does not handle [.subdir] notation
                path.gsub!(/\[(.*?)\]/){'/'+$1.gsub(/\./,'/').gsub(/-/,'..')+'/'}
                # FIXME: mangles UNC filepaths
                path=path.gsub(/\/+/,'/')
                path.sub!('/\/$','')
        		path
            end

            def self.unix_to_vms_path path
        		#FIXME: incomplete, untested
        		vmspath=path.clone
                # . => "" (handle beginning, end and middle of path)
        		vmspath.gsub!(/^\.(\/|$)/,'')
        		vmspath.gsub!(/\/\.(\/|$)/,'/')
                # .. => "-" (handle beginning, end and middle of path)
        		vmspath.gsub!(/^\.\.(\/|$)/,'-/')
        		vmspath.gsub!(/\/\.\.(\/|$)/,'/-/')
                # // => "/" (reduce multiple slashes to one)
        		vmspath.gsub!(/\/+/,'/')
                #
                # 1. For absolute paths (leading slash):
                # head of path "/xxx" is a device or logical name:
                # "/xxx" => "xxx:"
                #
                # 2. Take the basename and test it:
                # - if it exists
                #   - if it is a filename, treat as a filename
                #   - otherwise, treat as a directory
                # - otherwise
                #   - if it ends ".dir", lop off the suffix and treat
                #     as a dir
                #   - or if it has no extension, treat as a dir
                #   - otherwise treat as a file
                #
                # 3. If the basename was a filename, remove it from the
                #    path to add later.
                #
                # 4. Now take the remaining path (minus device or
                #    logical name and basename if it was a filename)
                #    and convert:
                # Absolute: ^/ => [
                # Relative: ^ => [.
                # / => "."
                # $ => "]"
                #
                # 5. And finally put together device, dir and
                #    filename.
            end
            
            class << self
                alias old_directory? directory?
                def directory? directory
                    if VMS::SystemInfo.vms_version > 702
                        old_directory? directory
                    else
                        normalized_directory=File.expand_path(directory)
                        normalized_directory.sub!(/((\/+)|(.dir(;-?(\d+)?)?))$/i,'')
                        # FIXME: to be precise, we would suffix ;1, but
                        # this seems to fail on VMS < V7.2 as well:
                        exists?(normalized_directory+".dir")
                    end
                end
            end
        end

        # Add support for one-shot write_mode (used to support $VMS_USE_FWRITE
        File::FWRITE_SENSITIVE_METHODS.each do |method|
            Aspect.weave File,method,
                :before=>%q[
                    # TODO: Should support multi-threading
                    $VMS_USE_FWRITE=(write_mode==:FWRITE)
                ],
                :after=>%[
                    $VMS_USE_FWRITE=false
                ]
        end

        # Ensure appended files are compatible with legacy open modes
        # This is only done for append mode as we can assume that if we are appending,
        # then the file is in ascii format.
        # - This does not support numeric file mode (ie. Fcntl::O_APPEND)
        #   due to lack of $VMS_FILE_MODE support for this case in io.c
        Aspect.class_weave File,:open,
            :before=>%q[
                $VMS_FILE_MODE='rfm=var;rat=cr' if String===args[1] and /a/i.match(args[1])
            ]

        class Dir
            class << self
                alias old_pwd pwd
            end

            def self.pwd
                File.expand_path(old_pwd)
            end
        end


        # VMS binary files handling patch:
        # --------------------------------
        # - Usually "Binary" files are hosted as fixed 512 bytes records.
        #   RMS maintains a First-Free-Byte field to record the logical EOF.
        #   The C RTL ignores this and allows reading past the FFB. The following
        #   compensates for this undesirable behaviour.
        
        class IO
            alias :original_binmode :binmode
    
            def binmode
                extend VMSBinmode # add smarter IO.read method
                original_binmode
            end
        end
        
        module VMSBinmode
            # read "clipped" user-requested bytes-to-read based on how many bytes left
            def read *args # ([length [, buffer]])  => string, buffer, or nil
                filesize=stat.size
                length=(length_specified=args.first) || filesize
                args[0]=[[filesize-pos,0].max,length].min
                args.first==0 ? (length_specified ? nil : '')  : super(*args)
            end
        end


        class VMS_ARG

            ERROR_MESSAGE,WILDCARD=/^([%-]| \\)/,/[\*\%]/

            def initialize
                vmsARGV=[]
                ARGV.each do |arg|
                    if WILDCARD.match(arg) && /^[^\/]/.match(arg) # Match none switch wildcarding
                        empty=true
                        expand arg do |filename|
                            vmsARGV << filename
                            empty=false
                        end
                        vmsARGV << arg if empty
                    else
                        vmsARGV << arg
                    end
                end
                ARGV.clear
                vmsARGV.each{|arg| ARGV << arg}
            end

            private

            def expand wildcard
                # NOTE: note that VMS dir generates a fully qualified filename. This donesn't match the Windows/Linux counterparts.
                `dir/noheader/notrailer #{wildcard}`.each{|filename| yield filename.chomp unless ERROR_MESSAGE.match filename}
            end
        end

        VMS_ARG.new    
end

# TODO: merge these into new vms_spec.rb
if $0==__FILE__
    require 'test/unit'
    class TestFileSupport < Test::Unit::TestCase
        case RUBY_PLATFORM
            when /VMS/i
                def test_file_expand_mixed
                    assert_equal \
                        "/DSA0/DM/LABCAN/app/controllers/labcan_controller.tbs",
                        File::expand_path('DSA0:[DM.LABCAN]/app/controllers/labcan_controller.tbs')
                end
                def test_file_expand_vms_abs_dir
                    assert_equal \
                        "/DSA0/DM/LABCAN/app/controllers",
                        File::expand_path('DSA0:[DM.LABCAN.app.controllers]')
                end
                def test_file_expand_vms_rel_dir_dash
                    assert_equal \
                        "/DSA0/DM/LABCAN/app/controllers",
                        File::expand_path('DSA0:[DM.LABCAN.app.views.-.controllers]')
                end
                def test_file_expand_vms_abs_dir_file
                    assert_equal \
                        "/DSA0/DM/LABCAN/app/controllers/labcan_controller.tbs",
                        File::expand_path('DSA0:[DM.LABCAN.app.controllers]labcan_controller.tbs')
                end
                def test_file_expand_unix_rel_dir_file
                    Dir.chdir("[DYMAX.001029]")
                    assert_equal \
                        "/DSA0/DYMAX/001029.DIR",
                        File::expand_path('../001029.DIR')
                end
                def test_file_expand_unix_rel_dir
                    Dir.chdir("[DYMAX.001029]")
                    assert_equal \
                        "/DSA0/DYMAX",
                        File::expand_path('..')
                end
                def test_file_expand_unix_rel_file
                    Dir.chdir("[DYMAX.001029]")
                    assert_equal \
                        "/DSA0/DYMAX/001029/INDEX.HTML",
                        File::expand_path('./INDEX.HTML')
                end                
                def test_file_expand_rel_file
                    Dir.chdir("[DYMAX.001029]")
                    assert_equal \
                        "/DSA0/DYMAX/001029/INDEX.HTML",
                        File::expand_path('INDEX.HTML')
                end                
                def test_directory_does_not_exist
                    assert_equal \
                        false,
                        File::directory?('/dym$disk/dymaxx')
                end
                def test_directory_exists_slash
                    assert_equal \
                        true,
                        File::directory?('/dym$disk/dymax/')
                end
                def test_directory_exists_noslash
                    assert_equal \
                        true,
                        File::directory?('/dym$disk/dymax')
                end
                def test_directory_exists_dir
                    assert_equal \
                        true,
                        File::directory?('/dym$disk/dymax.dir')
                end
                def test_directory_exists_dir_cur_version
                    assert_equal \
                        true,
                        File::directory?('/dym$disk/dymax.dir;')
                end
                def test_directory_exists_dir_version_num
                    assert_equal \
                        true,
                        File::directory?('/dym$disk/dymax.dir;1')
                end
                def test_directory_exists_subdir
                    assert_equal \
                        true,
                        File::directory?('/dym$disk/dymax/dyserver')
                end
        end
    end        
end

