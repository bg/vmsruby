$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestDir < Rubicon::TestCase

  def setup
    setupTestDir
  end

  def teardown
    teardownTestDir
  end

  def delete_test_dir
    MsWin32.only do sys("del _test /s /q >nul") end
    MsWin32.dont do sys("rm _test/*") end
  end

  def test_s_aref
    [
      [ %w( _test ),                     Dir["_test"] ],
      [ %w( _test/ ),                    Dir["_test/"] ],
      [ %w( _test/_file1 _test/_file2 ), Dir["_test/*"] ],
      [ %w( _test/_file1 _test/_file2 ), Dir["_test/_file*"] ],
      [ %w(  ),                          Dir["_test/frog*"] ],
      
      [ %w( _test/_file1 _test/_file2 ), Dir["**/_file*"] ],
      
      [ %w( _test/_file1 _test/_file2 ), Dir["_test/_file[0-9]*"] ],
      [ %w( ),                           Dir["_test/_file[a-z]*"] ],
      
      [ %w( _test/_file1 _test/_file2 ), Dir["_test/_file{0,1,2,3}"] ],
      [ %w( ),                           Dir["_test/_file{4,5,6,7}"] ],
      
      [ %w( _test/_file1 _test/_file2 ), Dir["**/_f*[il]l*"] ],    
      [ %w( _test/_file1 _test/_file2 ), Dir["**/_f*[il]e[0-9]"] ],
      [ %w( _test/_file1              ), Dir["**/_f*[il]e[01]"] ],
      [ %w( _test/_file1              ), Dir["**/_f*[il]e[01]*"] ],
      [ %w( _test/_file1              ), Dir["**/_f*[^ie]e[01]*"] ],
    ].each do |expected, got|
      assert_set_equal(expected, got)
    end
  end

  # Helper method to test_s_chdir.
  # Sets/restores some of HOME / LOGDIR.
  # Yields to the caller with the changed settings.
  def with_home_logdir(vars_set)
    all_vars = ["HOME", "LOGDIR"]
    to_restore = {}
    begin
      for var in all_vars
        to_restore[var] = ENV[var]
        if vars_set.include?(var)
          ENV[var] = "subdir_#{var}"
        else
          ENV.delete(var)
        end
      end
      yield
    ensure
      for var in all_vars
        value = to_restore[var]
        if value
          ENV[var] = value
        else
          ENV.delete(var)
        end
      end
    end
  end

  def test_s_chdir
    start = Dir.getwd
    assert_raises(Errno::ENOENT)       { Dir.chdir "_wombat" }
    assert_equal(0,                         Dir.chdir("_test"))
    assert_equal(File.join(start, "_test"), Dir.getwd)
    assert_equal(0,                         Dir.chdir(".."))
    assert_equal(start,                     Dir.getwd)

    # chdir with block to existing dir.
    # Parameter to block same value as parameter to chdir.
    assert_equal(start, Dir.getwd)
    Dir.chdir("_test") do |dir_param|
      assert_equal(File.join(start, "_test"), Dir.getwd)
      assert_equal("_test", dir_param)
    end
    assert_equal(start, Dir.getwd)

    # chdir with block.
    # No parameter to chdir => meaning "home dir".
    # Parameter to block nil (because no parameter to chdir)
    # Check all combinations of HOME and LOGDIR by explicitly
    # setting/unsetting them.
    #
    home_logdir_tests = [
      [[],                 nil],
      [["HOME"],           "HOME"],
      [["LOGDIR"],         "LOGDIR"],
      [["HOME", "LOGDIR"], "HOME"],
    ]
    Dir.chdir("_test") do
      Dir.mkdir("subdir_HOME")
      Dir.mkdir("subdir_LOGDIR")
      for vars_set, res in home_logdir_tests
        with_home_logdir(vars_set) do
          assert_equal(File.join(start, "_test"), Dir.getwd)
          if res
            Dir.chdir() do |dir_param|
              assert_equal(File.join(start, "_test","subdir_#{res}"),
                           Dir.getwd)
              Version.less_than("1.8.2") do
                assert_equal(nil, dir_param)
              end
              Version.greater_or_equal("1.8.2") do
                assert_equal("subdir_#{res}", dir_param)
              end
            end
            assert_equal(File.join(start, "_test"), Dir.getwd)
          else
            # none of HOME and LOGDIR set
            assert_raises(ArgumentError) do
              Dir.chdir() do |dir_param|
                # not reached
                assert(false)
              end
            end
          end
        end
      end
    end

    # chdir with block to non-existing dir
    assert_raises(Errno::ENOENT) do
      Dir.chdir("_wombat") do
        # never reached
      end
    end

    # chdir with block to non-existing dir, and a directory above that
    # is unaccessible => we should still get Errno::ENOENT.
    Dir.chdir("_test") do
      Dir.mkdir("inaccessible")
      Dir.mkdir("inaccessible/subdir")
      Dir.chdir("inaccessible/subdir") do
        old_mode = File.stat("..").mode
        begin
          File.chmod(0, "..")  # make "inaccessible" live up to its name
          assert_raises(Errno::ENOENT) do
            Dir.chdir("non-existing") do
              # never reached
            end
          end
        ensure
          File.chmod(old_mode, "..")  # restore "inaccessible"
        end
      end
    end

    MsWin32.only do
      a_win_abs_path = (ENV["SystemRoot"] || "C:/Program Files").dup
      a_win_abs_path.gsub!(/\\/, "/")

      assert_equal(0,                       Dir.chdir(a_win_abs_path));
      assert_equal(a_win_abs_path,          Dir.getwd)
    end
    MsWin32.dont do
      assert_equal(0,                       Dir.chdir("/"))
      assert_equal("/",                  Dir.getwd)
    end
  end

  def test_s_chroot
    super_user
  end

  def test_s_delete
    generic_test_s_rmdir(:delete)
  end

  def test_s_entries
    assert_raises(Errno::ENOENT)      { Dir.entries "_wombat" } 
    assert_raises(Errno::ENOENT)      { Dir.entries "_test/file*" } 
    assert_set_equal(@files, Dir.entries("_test"))
    assert_set_equal(@files, Dir.entries("_test/."))
    assert_set_equal(@files, Dir.entries("_test/../_test"))
  end

  def test_s_foreach
    got = []
    entry = nil
    assert_raises(Errno::ENOENT) { Dir.foreach("_wombat") {}}
    assert_nil(Dir.foreach("_test") { |f| got << f } )
    assert_set_equal(@files, got)
  end

  def test_s_getwd
    MsWin32.only do
      assert_equal(`cd`.chomp.gsub(/\\/, '/'), Dir.getwd)
    end
    MsWin32.dont do
      assert_equal(`pwd`.chomp, Dir.getwd)
    end
  end

  def test_s_glob
    [
      [ %w( _test ),                     Dir.glob("_test") ],
      [ %w( _test/ ),                    Dir.glob("_test/") ],
      [ %w( _test/_file1 _test/_file2 ), Dir.glob("_test/*") ],
      [ %w( _test/_file1 _test/_file2 ), Dir.glob("_test/_file*") ],
      [ %w(  ),                          Dir.glob("_test/frog*") ],
      
      [ %w( _test/_file1 _test/_file2 ), Dir.glob("**/_file*") ],
      
      [ %w( _test/_file1 _test/_file2 ), Dir.glob("_test/_file[0-9]*") ],
      [ %w( ),                           Dir.glob("_test/_file[a-z]*") ],
      
      [ %w( _test/_file1 _test/_file2 ), Dir.glob("_test/_file{0,1,2,3}") ],
      [ %w( ),                           Dir.glob("_test/_file{4,5,6,7}") ],
      
      [ %w( _test/_file1 _test/_file2 ), Dir.glob("**/_f*[il]l*") ],
      [ %w( _test/_file1 _test/_file2 ), Dir.glob("**/_f*[il]e[0-9]") ],
      [ %w( _test/_file1              ), Dir.glob("**/_f*[il]e[01]") ],
      [ %w( _test/_file1              ), Dir.glob("**/_f*[il]e[01]*") ],
      [ %w( _test/_file1              ), Dir.glob("**/_f*[^ie]e[01]*") ],
    ].each do |expected, got|
      assert_set_equal(expected, got)
    end
  end

  def test_s_mkdir
    assert_equal(0, Dir.chdir("_test"))
    assert_equal(0, Dir.mkdir("_lower1"))
    assert(File.stat("_lower1").directory?)
    assert_equal(0, Dir.chdir("_lower1"))
    assert_equal(0, Dir.chdir(".."))
    assert_equal(0, Dir.mkdir("_lower2", 0777))
    skipping "Anyone think of a way to test permissions?"
    assert_equal(0, Dir.delete("_lower1"))
    assert_equal(0, Dir.delete("_lower2"))
  end

  def test_s_new
    assert_raises(ArgumentError) { Dir.new }
    assert_raises(ArgumentError) { Dir.new("a", "b") }
    assert_raises(Errno::ENOENT) { Dir.new("_wombat") }

    assert_equal(Dir, Dir.new(".").class)
  end

  def test_s_open
    assert_raises(ArgumentError) { Dir.open }
    assert_raises(ArgumentError) { Dir.open("a", "b") }
    assert_raises(Errno::ENOENT) { Dir.open("_wombat") }

    assert_equal(Dir, Dir.open(".").class)
    assert_nil(Dir.open(".") { |d| assert_equal(Dir, d.class) } )
  end

  def test_s_pwd
    MsWin32.only do
      assert_equal(`cd`.chomp.gsub(/\\/, '/'), Dir.pwd)
    end
    MsWin32.dont do
      assert_equal(`pwd`.chomp, Dir.pwd)
    end
  end

  def test_s_rmdir
    generic_test_s_rmdir(:rmdir)
  end

  def generic_test_s_rmdir(method)
    assert_raise(Errno::ENOENT, SystemCallError) do
      Dir.send(method, "_wombat")
    end

    exceptions_ENOTEMPTY = [Errno::ENOTEMPTY, SystemCallError]
    if $os <= Solaris
      # On Solaris, the system call rmdir(2) returns EEXIST if
      # a directory is not empty. The man page says:
      #
      #    EEXIST
      #        The directory contains entries other  than  those  for
      #        "." and "..".
      #
      # I don't know why Solaris differs from for example
      # Linux and FreeBSD here, but it seems to be a fact.
      #
      exceptions_ENOTEMPTY << Errno::EEXIST
    end
    assert_raise(*exceptions_ENOTEMPTY) { Dir.send(method, "_test") } 

    delete_test_dir
    assert_equal(0, Dir.send(method, "_test"))
    assert_raise(Errno::ENOENT, SystemCallError)    { Dir.send(method, "_test") } 
  end

  def test_s_unlink
    generic_test_s_rmdir(:unlink)
  end

  def test_close
    d = Dir.new(".")
    d.read
    assert_nil(d.close)
    assert_raises(IOError) { d.read }
  end

  def test_each
    got = []
    d = Dir.new("_test")
    assert_equal(d, d.each { |f| got << f })
    assert_set_equal(@files, got)
    d.close
  end

  def test_read
    d = Dir.new("_test")
    got = []
    entry = nil
    got << entry while entry = d.read
    assert_set_equal(@files, got)
    d.close
  end

  def test_rewind
    d = Dir.new("_test")
    entry = nil
    got = []
    got << entry while entry = d.read
    assert_set_equal(@files, got)
    d.rewind
    got = []
    got << entry while entry = d.read
    assert_set_equal(@files, got)
    d.close
  end

  def test_seek
    d = Dir.new("_test")
    d.read
    pos = d.tell
    assert_equal(Fixnum, pos.class)
    name = d.read
    assert_equal(d, d.seek(pos))
    assert_equal(name, d.read)
    d.close
  end

  def test_tell
    d = Dir.new("_test")
    d.read
    pos = d.tell
    assert_equal(Fixnum, pos.class)
    name = d.read
    assert_equal(d, d.seek(pos))
    assert_equal(name, d.read)
    d.close
  end

  def test_improper_close
    teardownTestDir
    Cygwin.known_problem do
      Dir.mkdir("_test")
      d = Dir.new("_test")
      Dir.rmdir("_test")
      begin
        Dir.mkdir("_test")
      rescue
        raise Test::Unit::AssertionFailedError
      ensure
        d.close
      end
    end
  end
  
end

Rubicon::handleTests(TestDir) if $0 == __FILE__
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                