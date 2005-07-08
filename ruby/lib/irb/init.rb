#
#   irb/init.rb - irb initialize module
#   	$Release Version: 0.9$
#   	$Revision: 1.6.2.1 $
#   	$Date: 2004/03/10 08:21:02 $
#   	by Keiju ISHITSUKA(keiju@ishitsuka.com)
#
# --
#
#   
#

module IRB

  # initialize config
  def IRB.setup(ap_path)
    IRB.init_config(ap_path)
    IRB.init_error
    IRB.parse_opts
    IRB.run_config
    IRB.load_modules

    unless @CONF[:PROMPT][@CONF[:PROMPT_MODE]]
      IRB.fail(UndefinedPromptMode, @CONF[:PROMPT_MODE]) 
    end
  end

  # @CONF default setting
  def IRB.init_config(ap_path)
    # class instance variables
    @TRACER_INITIALIZED = false

    # default configurations
    unless ap_path and @CONF[:AP_NAME]
      ap_path = File.join(File.dirname(File.dirname(__FILE__)), "irb.rb")
    end
    @CONF[:AP_NAME] = File::basename(ap_path, ".rb")

    @CONF[:IRB_NAME] = "irb"
    @CONF[:IRB_LIB_PATH] = File.dirname(__FILE__)

    @CONF[:RC] = true
    @CONF[:LOAD_MODULES] = []
    @CONF[:IRB_RC] = nil

    @CONF[:MATH_MODE] = false
    @CONF[:USE_READLINE] = false unless defined?(ReadlineInputMethod)
    @CONF[:INSPECT_MODE] = nil
    @CONF[:USE_TRACER] = false
    @CONF[:USE_LOADER] = false
    @CONF[:IGNORE_SIGINT] = true
    @CONF[:IGNORE_EOF] = false
    @CONF[:ECHO] = nil
    @CONF[:VERBOSE] = nil

    @CONF[:EVAL_HISTORY] = nil

    @CONF[:BACK_TRACE_LIMIT] = 16

    @CONF[:PROMPT] = {
      :NULL => {
	:PROMPT_I => nil,
	:PROMPT_S => nil,
	:PROMPT_C => nil,
	:RETURN => "%s\n"
      },
      :DEFAULT => {
	:PROMPT_I => "%N(%m):%03n:%i> ",
	:PROMPT_S => "%N(%m):%03n:%i%l ",
	:PROMPT_C => "%N(%m):%03n:%i* ",
	:RETURN => "=> %s\n"
      },
      :CLASSIC => {
	:PROMPT_I => "%N(%m):%03n:%i> ",
	:PROMPT_S => "%N(%m):%03n:%i%l ",
	:PROMPT_C => "%N(%m):%03n:%i* ",
	:RETURN => "%s\n"
      },
      :SIMPLE => {
	:PROMPT_I => ">> ",
	:PROMPT_S => nil,
	:PROMPT_C => "?> ",
	:RETURN => "=> %s\n"
      },
      :INF_RUBY => {
	:PROMPT_I => "%N(%m):%03n:%i> ",
	:PROMPT_S => nil,
	:PROMPT_C => nil,
	:RETURN => "%s\n",
	:AUTO_INDENT => true
      },
      :XMP => {
	:PROMPT_I => nil,
	:PROMPT_S => nil,
	:PROMPT_C => nil,
	:RETURN => "    ==>%s\n"
      }
    }

    @CONF[:PROMPT_MODE] = :DEFAULT
    @CONF[:AUTO_INDENT] = false

    @CONF[:CONTEXT_MODE] = 3 # use binding in function on TOPLEVEL_BINDING
    @CONF[:SINGLE_IRB] = false

#    @CONF[:LC_MESSAGES] = "en"
    @CONF[:LC_MESSAGES] = Locale.new
    
    @CONF[:DEBUG_LEVEL] = 1
  end

  def IRB.init_error
    @CONF[:LC_MESSAGES].load("irb/error.rb")
  end

  # option analyzing
  def IRB.parse_opts
    while opt = ARGV.shift
      case opt
      when "-f"
	@CONF[:RC] = false
      when "-m"
	@CONF[:MATH_MODE] = true
      when "-d"
	$DEBUG = true
      when "-r"
	opt = ARGV.shift
	@CONF[:LOAD_MODULES].push opt if opt
      when "-I"
        opt = ARGV.shift
        $LOAD_PATH.push opt if opt
      when /^-K(.)/
	$KCODE = $1
      when "--inspect"
	@CONF[:INSPECT_MODE] = true
      when "--noinspect"
	@CONF[:INSPECT_MODE] = false
      when "--readline"
	@CONF[:USE_READLINE] = true
      when "--noreadline"
	@CONF[:USE_READLINE] = false
      when "--echo"
	@CONF[:ECHO] = true
      when "--noecho"
	@CONF[:ECHO] = false
      when "--verbose"
	@CONF[:VERBOSE] = true
      when "--noverbose"
	@CONF[:VERBOSE] = false
      when "--prompt-mode", "--prompt"
	prompt_mode = ARGV.shift.upcase.tr("-", "_").intern
	@CONF[:PROMPT_MODE] = prompt_mode
      when "--noprompt"
	@CONF[:PROMPT_MODE] = :NULL
      when "--inf-ruby-mode"
	@CONF[:PROMPT_MODE] = :INF_RUBY
      when "--sample-book-mode", "--simple-prompt"
	@CONF[:PROMPT_MODE] = :SIMPLE
      when "--tracer"
	@CONF[:USE_TRACER] = true
      when "--back-trace-limit"
	@CONF[:BACK_TRACE_LIMIT] = ARGV.shift.to_i
      when "--context-mode"
	@CONF[:CONTEXT_MODE] = ARGV.shift.to_i
      when "--single-irb"
	@CONF[:SINGLE_IRB] = true
      when "--irb_debug"
	@CONF[:DEBUG_LEVEL] = ARGV.shift.to_i
      when "-v", "--version"
	print IRB.version, "\n"
	exit 0
      when "-h", "--help"
	require "irb/help"
	IRB.print_usage
	exit 0
      when /^-/
	IRB.fail UnrecognizedSwitch, opt
      else
	@CONF[:SCRIPT] = opt
	$0 = opt
	break
      end
    end
  end

  # running config
  def IRB.run_config
    if @CONF[:RC]
      rcs = []
      rcs.push File.expand_path("~/.irbrc") if ENV.key?("HOME")
      rcs.push ".irbrc"
      rcs.push "irb.rc"
      rcs.push "_irbrc"
      rcs.push "$irbrc"
      catch(:EXIT) do
	for rc in rcs
	  begin
	    load rc
	    throw :EXIT
	  rescue LoadError, Errno::ENOENT
	  rescue
	    print "load error: #{rc}\n"
	    print $!.class, ": ", $!, "\n"
	    for err in $@[0, $@.size - 2]
	      print "\t", err, "\n"
	    end
	    throw :EXIT
	  end
	end
      end
    end
  end

  # loading modules
  def IRB.load_modules
    for m in @CONF[:LOAD_MODULES]
      begin
	require m
      rescue
	print $@[0], ":", $!.class, ": ", $!, "\n"
      end
    end
  end

end
