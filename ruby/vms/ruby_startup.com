$ IF P1 .EQS. ""
$ THEN myself = "SYS$COMMON:[RUBY]"
$ ELSE myself = P1
$ ENDIF
$
$ IF P2 .EQS. ""
$ THEN flags = "/SYSTEM/EXECUTIVE"
$ ELSE flags = P2
$ ENDIF
$
$ DEFINE  := DEFINE/NOLOG
$ XDEFINE := DEFINE/NOLOG/TRANSLATION=(CONCEALED,TERMINAL)
$
$ xmyself = F$PARSE(myself,,,,"NO_CONCEAL")	
$ xhere   = F$PARSE(xmyself,,,"DEVICE") + F$PARSE(xmyself,,,"DIRECTORY") - "][" - "]" + ".]"
$
$ XDEFINE'flags' RUBY_ROOT        'xhere'
$ DEFINE'flags'  RUBY_LIBROOT     RUBY_ROOT:[LIB]
$ DEFINE'flags'  RUBY_INCLUDE     RUBY_ROOT:[SRC]
$ DEFINE'flags'  RUBY_INTERPRETER RUBY_ROOT:[000000]RUBY_INTERPRETER.EXE
$ DEFINE'flags'  RUBYSHR          RUBY_ROOT:[000000]RUBYSHR.EXE
$
$ EXIT
