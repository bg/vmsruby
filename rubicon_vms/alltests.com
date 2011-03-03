$ PROCEDURE_NAME=F$ENVIRONMENT("PROCEDURE")
$ SAVED_DIR=F$TRNLNM("SYS$DISK")+F$DIRECTORY()
$ TEST_DIR=F$PARSE(PROCEDURE_NAME,,,"DEVICE") -
  +F$PARSE(PROCEDURE_NAME,,,"DIRECTORY")-"]["
$ SET DEF 'TEST_DIR'
$ ON CONTROL_Y THEN GOTO FINISH
$ ON ERROR THEN GOTO FINISH
$ @AASETUP
$ DEFINE/USER SYS$ERROR RUBICON_ERR.LOG
$ RUBY ALLTESTS.RB >RUBICON.LOG
$ FINISH:
$ SET DEF 'SAVED_DIR'
