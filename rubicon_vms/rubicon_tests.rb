#
# This is the main Rubicon module, implemented as a module to
# protect the namespace a tad
#

RUBICON_VERSION = "V0.3.5"

require 'test/unit'
require 'test/unit/ui/console/testrunner.rb'
Test::Unit.run = true
module Test
  module Unit
   class TestResult
     attr_accessor :failures, :errors
   end
  end
end


module Rubicon
  #
  # Common code to run the tests in a class
  #
  def self.handleTests(testClass)
#    TestRunner.quiet_mode = true
    suite=nil
    if ARGV.size == 0
      suite = testClass.suite
    else
      suite = Test::Unit::TestSuite.new
      ARGV.each do |testmethod|
        suite << testClass.new(testmethod)
      end
    end
    Test::Unit.run = true
    testrunner = Rubicon::TestRunner.new(suite, Test::Unit::UI::VERBOSE)
    results = testrunner.start
  end

  # -------------------------------------------------------

  class TestResult < Test::Unit::TestResult
  end

  # -------------------------------------------------------

  class TestRunner < Test::Unit::UI::Console::TestRunner
    def create_result
      TestResult.new
    end
  end

  # -------------------------------------------------------

  class TestSuite < Test::Unit::TestSuite
  end


  # -------------------------------------------------------

  class TestCase < Test::Unit::TestCase

    # Ruby uses the functions stat(2) and chmod(2) to manipulate
    # file permissions. One Windows there is an implementation of these
    # functions that tries to "emulate" the behaviour on Unix.
    # But all you can really do on Windows is to turn the readonly flag
    # on/off. The MSDN documentation of _chmod says:
    #
    #   "If write permission is not given, the file is read-only.
    #    Note that all files are always readable; it is not possible
    #    to give write-only permission".
    #
    # So the _fstat_map method below reflects the way stat/chmod
    # works on Windows. 
    #
    def _fstat_map(mode)
      if $os <= Windows
        mode |= 0444
        if (mode & 0200) != 0
          mode |= 0222
        end
      end
      mode
    end

    # In addition to the chmod/stat behaviour on Windows described above,
    # Ruby also adds a twist all by itself: the Ruby source code on
    # Windows masks the "mode" value returned from the system so that
    # 0666 becomes 0644 (the code is in win32\win32.c in the function
    # "rb_w32_stat").
    #
    # I don't know the reason for this.
    # But the _stat_map method below reflects the fact that this mapping
    # occurs in Ruby.
    #
    def _stat_map(mode)
      mode = _fstat_map(mode)
      if $os <= Windows
        mode &= ~0022
      end
      mode
    end

    # Local routine to check that a set of bits, and only a set of bits,
    # is set!
    def checkBits(bits, num)
      0.upto(90)  { |n|
        expected = bits.include?(n) ? 1 : 0
        assert_equal(expected, num[n], "bit %d" % n)
      }
    end

    def truth_table(method, *result)
      for a in [ false, true ]
        res = result.shift
        assert_equal(method.call(a), res)
        assert_equal(method.call(a ? self : nil), res)
      end
    end

    # 
    # Report we're skipping a test
    #
    def skipping(info, from=nil)
      unless from
        caller[0] =~ /`(.*)'/ #`
        from = $1
      end
      if true
        $stderr.print "S"
      else
        $stderr.puts "\nSkipping: #{from} - #{info}"
      end
    end

    #
    # Don't interpret no testcases in file as an error
    #
    def default_test
    end

    #
    # Check a float for approximate equality
    #
    def assert_flequal(exp, actual, msg='')
      if exp == 0.0
        error = 1e-7
      else
        error = exp.abs/1e7
      end
      
      assert((exp - actual).abs < error, 
             "#{msg} Expected #{'%f' % exp} got #{'%f' % actual}")
    end

    def assert_kindof_exception(exception, message="")
      #CEF added this{}
      block = proc{}
      exception_raised = true
      err = ""
      ret = nil
      begin
	block.call
	exception_raised = false
	err = 'NO EXCEPTION RAISED'
      rescue Exception
	if $!.kind_of?(exception)
	  exception_raised = true
	  ret = $!
	else
	  raise $!.type, $!.message, $!.backtrace
	end
      end
      if !exception_raised
      	msg = edit_message(message)
        msg.concat "expected:<"
	msg.concat to_str(exception)
	msg.concat "> but was:<"
	msg.concat to_str(err)
	msg.concat ">"
	raise_assertion_error(msg, 2)
      end
      ret
    end

    #
    # Skip a test if not super user
    #
    def super_user
      caller[0] =~ /`(.*)'/ #`
      skipping("not super user", $1)
    end

    #
    # Issue a system and abort on error
    #
    def sys(cmd)
      if $os == MsWin32
	assert(system(cmd), "command failed: #{cmd}")
      else
	assert(system(cmd), cmd + ": #{$? >> 8}")
	assert_equal(0, $?, "cmd: #{$?}")
      end
    end

    #
    # Use our 'test_touch' utility to touch a file
    #
    def touch(arg)
#      puts("#{TEST_TOUCH} #{arg}")
      sys("#{TEST_TOUCH} #{arg}")
    end

    #
    # And out checkstat utility to get the status
    #
    def checkstat(arg)
#      puts("#{CHECKSTAT} #{arg}")
      `#{CHECKSTAT} #{arg}`
    end

    #
    # Check two arrays for set equality
    #
    def assert_set_equal(expected, actual)
      expected_left = expected.dup
      actual.each do |x|
        if j = expected_left.index(x)
          expected_left.slice!(j)
        end
      end
      assert( expected.length == actual.length && expected_left.length == 0,
             "Expected: #{expected.inspect}, Actual: #{actual.inspect}")
    end

    #
    # Run a block in a sub process and return exit status
    #
    def runChild(&block)
      pid = fork 
      if pid.nil?
	block.call
        exit 0
      end
      Process.waitpid(pid, 0)
      return ($? >> 8) & 0xff
    end

    def setup
      super
    end

    def teardown
      if $os != MsWin32 && $os != JRuby
	begin
	  loop { Process.wait; $stderr.puts "\n\nCHILD REAPED\n\n" }
	rescue Errno::ECHILD
	end
      end
      super
    end
    #
    # Setup some files in a test directory.
    #
    def setupTestDir
      @start = Dir.getwd
      teardownTestDir
      begin
	Dir.mkdir("_test")
      rescue
        $stderr.puts "Cannot run a file or directory test: " + 
          "will destroy existing directory _test"
	# VMS maps exit status 99 (octal 143) as a meaningless
	# message "%SYSTEM-?-DRVERR, fatal drive error".
	exit
#       exit(99)
      end
      File.open(File.join("_test", "_file1"), "w", 0644) {}
      File.open(File.join("_test", "_file2"), "w", 0644) {}
      @files = %w(. .. _file1 _file2)
    end
    
    def deldir(name)
      File.chmod(0755, name)
      Dir.foreach(name) do |f|
        next if f == '.' || f == '..'
        f = File.join(name, f)
        if File.lstat(f).directory?
          deldir(f) 
        else
          File.chmod(0644, f) rescue true
          File.delete(f)
        end 
      end
      Dir.rmdir(name)
    end

    def teardownTestDir
      Dir.chdir(@start)
      deldir("_test") if (File.exists?("_test"))
    end
    
  end

    


  # Record a particule failure, which is a location
  # and an error message. We simply ape the Test::Unit
  # TestFailure class.

  class Failure
    attr_accessor :at
    attr_accessor :err
    
    def Failure.from_real_failures(f)
      f.collect do |a_failure|
        my_f = Failure.new
        if(a_failure.respond_to?(:exception)) then
          my_f.at = a_failure.test_name
          my_f.err = a_failure.exception
        else
          my_f.at = a_failure.location
          my_f.err = a_failure.message
        end
        my_f
      end
    end
  end

  # Objects of this class get generated from the TestResult
  # passed back by Test::Unit. We don't use it's class for two reasons:
  # 1. We decouple better this way
  # 2. We can't serialize the Test::Unit class, as it contains IO objects CHECK THIS FOR ACCURACY!
  #

  
  class Results
    attr_reader :failure_size
    attr_reader :error_size
    attr_reader :run_tests
    attr_reader :run_asserts
    attr_reader :failures
    attr_reader :errors


    def initialize_from(test_result)
      @failure_size = test_result.failure_count
      @error_size   = test_result.error_count
      @run_tests    = test_result.run_count
      @run_asserts  = test_result.assertion_count
      @succeed      = test_result.passed?
      @failures     = Failure.from_real_failures(test_result.failures)
      @errors       = Failure.from_real_failures(test_result.errors)
      self
    end

    def succeed?
      @succeed
    end
  end

  # And here is where we gather the results of all the tests. This is
  # also the object exported to XML

  class ResultGatherer

    attr_reader   :results
    attr_accessor :name
    attr_reader   :config
    attr_reader   :date
    attr_reader   :rubicon_version
    attr_reader   :ruby_version
    attr_reader   :ruby_release_date
    attr_reader   :ruby_architecture

    attr_reader   :failure_count

    # Two sage initialization, so that Rubric doesn't create all the
    # internals when we unmarshal

    def initialize(name = '')
      @name    = ''
      @failure_count = 0
    end

    def setup
      @results = {}
      @config  = Config::CONFIG
      @date    = Time.now
      @rubicon_version = RUBICON_VERSION

      ver = `#$interpreter --version`
      # ruby 1.7.1 (2001-07-26) [i686-linux]  
      unless ver =~ /ruby (\d+\.\d+\.\d+)\s+\((.*?)\)\s+\[(.*?)\]/
#        raise "Couldn't find version in '#{ver}'" 
      end
      @ruby_version      = $1
      @ruby_release_date = $2
      @ruby_architecture = $3
      self
    end

    def add(klass, result_set)
      @results[klass.name] = Results.new.initialize_from(result_set)
      @failure_count += result_set.error_count + result_set.failure_count
    end
    
  end

  # Run a set of tests in a file. This would be a TestSuite, but we
  # want to run each file separately, and to summarize the results
  # differently

  class BulkTestRunner

    def initialize(args, group_name)
      @groupName = group_name
      @files     = []
      @results   = ResultGatherer.new.setup
      @results.name   = group_name
      @op_class_file  = "ascii"

      # Look for a -op <class> argument, which controls
      # where our output goes

      if args.size > 1 and args[0] == "-op"
        args.shift
        @op_class_file = args.shift
      end

      @op_class_file = "result_" + @op_class_file
      require @op_class_file
    end

    def addFile(fileName)
      @files << fileName
    end

    def classEach
      list=[]
      ObjectSpace.each_object(Class){|aClass| list << aClass}
      list.sort{|a,b| a.to_s.upcase <=> b.to_s.upcase}.each{|entry| yield entry.to_s}
    end

    def casedClassName(name)
      upcasedName=name.upcase
      cased=nil
      classEach{|className| cased=className if className.upcase==upcasedName}
      cased
    end

    def run
      Test::Unit.run = true

      @files.each do |file|
        require file
        # On systems which don't support mixed case filenames
        # (principally VMS) the uncasedClassName will not match
        # the casing of the actual class name.  On such systems,
        # casedClassName() ensures the filename is matched to a
        # class of the same name already loaded into object space.
        uncasedClassName = File.basename(file)
        uncasedClassName.sub!(/\.rb$/, '')
        className = casedClassName(uncasedClassName)
        klass = eval className
        runner = TestRunner.new(klass.suite, Test::Unit::UI::SILENT)
        #TestRunner.quiet_mode = true
        $stderr.print "\n", className, ": "

        @results.add(klass, runner.start)
      end

      reporter = ResultDisplay.new(@results)
      reporter.reportOn $stdout
      return @results.failure_count
    end

  end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   a 70020     Yukon Gold                                                               u¨  
   !            
q   2         
q°                                                
q
q                                                  	        `                                                                                                                                                                                                                                                               `                                                                                                                                                                                                                                                          a                                                                                                                                                                                                                                                              b 80011     The secret to a great lawn                                               uT  0                 
q                
q¾                                         <       
q
q "                                                	    "   d                                                                                                                                                                                                                                                              b01868     Dysthymic Disorder and Major Affective Disorders (Cases 1-4)                       Ç                 234     
q¯       P                             	`     
I                                                            c 10030     Man's Cosmic Status                                                                  6             498.4   
q§                                              
I                                                    H             cVL46A     Sol at the Travel Agency                                                =¨     z    *      á 625.3   
qº        J                                
      
I
q    VL046                                         	        d S0001     Digital Computer Techniques                                                  ¨   ç         ¯         
qª       HC                                     
I                                                              g VL46C     Sol and the Sailboat                                                       T  ’    *      } 625.6   
qº        J                                
      
I
q +  VL046                                         	    +   e                                                                                                                                                                                                                                                               e                                                                                                                                                                                                                                                          f                                                                                                                                                                                                                                                              