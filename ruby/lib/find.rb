module Find
    # Calls the associated block with the name of every file and directory listed
    # as arguments, then recursively on their subdirectories, and so on.
    #
    # See the +Find+ module documentation for an example.
    def find *paths  # :yield: path
        paths.collect!{|path| path.dup} # Why?
        while path=paths.shift
            catch :prune do
                yield path.dup.taint
                next unless File.exist? path
                begin
                    if File.lstat(path).directory?
                        dir=Dir.open path
                        begin
                            for file in dir
                                if path=~/(^.*?)\](.*?)\.DIR;\d+/i
                                    file=$1+'.'+$2+']'+file
                                else
                                    file=path+file
                                end
                                paths.unshift file.untaint
                            end
                        ensure
                            dir.close
                        end
                    end
                    rescue Errno::ENOENT, Errno::EACCES
                end
            end
        end
    end

    # Skips the current file or directory, restarting the loop with the next
    # entry. If the current file is a directory, that directory will not be
    # recursively entered. Meaningful only within the block associated with
    # Find::find.
    #
    # See the +Find+ module documentation for an example.
    def prune
        throw :prune
    end

    module_function :find, :prune
end

if $0==__FILE__

    Find.find '[DYMAX.PRO.RUBY]' do |file|
        type=case
            when File.file?(file): "F"
            when File.directory?(file): "D"
            else "?"
        end
        puts "#{type}: #{file}"
        Find.prune if file =~ /OBS/i
    end

end