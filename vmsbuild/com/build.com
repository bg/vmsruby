$! BUILD.COM P1
$!
$!   P1 - start phase (SETUP, [CLEANUP], MAKE, EXTLIB, BLDLIB, KITGEN)
$
$ RUBY_STREAM   = "018"
$
$ on_vax   = F$GETSYI("ARCH_NAME") .EQS. "VAX"
$ on_alpha = F$GETSYI("ARCH_NAME") .EQS. "Alpha"
$ on_ia64  = F$GETSYI("ARCH_NAME") .EQS. "IA64"
$
$ IF on_vax   THEN RUBY_PLATFORM = "vax-vms"
$ IF on_alpha THEN RUBY_PLATFORM = "alpha-vms"
$ IF on_ia64  THEN RUBY_PLATFORM = "ia64-vms"
$
$ DEFINE  := DEFINE/NOLOG
$ XDEFINE := DEFINE/NOLOG/TRANSLATION=(CONCEALED,TERMINAL)
$
$ RUBY_SITE_LIB2    = "/RUBY_LIBROOT/site_ruby/''RUBY_STREAM'"
$ RUBY_SITE_ARCHLIB = "/RUBY_LIBROOT/site_ruby/''RUBY_STREAM'/''RUBY_PLATFORM'"
$ RUBY_SITE_LIB     = "/RUBY_LIBROOT/site_ruby"
$ RUBY_LIB          = "/RUBY_LIBROOT/''RUBY_STREAM'"
$ RUBY_ARCHLIB      = "/RUBY_LIBROOT/''RUBY_STREAM'/''RUBY_PLATFORM'"
$
$ proc = F$PARSE(F$ENVIRONMENT("PROCEDURE"),,,,"NO_CONCEAL") - "]["
$ here = F$PARSE(proc,,,"DEVICE") + F$PARSE(proc,,,"DIRECTORY")
$
$ srcroot = here - "]" + ".--.RUBY]"
$ srcroot = F$PARSE(srcroot,,,,"NO_CONCEAL,SYNTAX_ONLY") 
$ srcroot = srcroot - "][" - "].;" + ".]"
$
$ bldroot = here - "]" + ".--.VMSBUILD]"
$ bldroot = F$PARSE(bldroot,,,,"NO_CONCEAL,SYNTAX_ONLY") 
$ bldroot = bldroot - "][" - "].;" + ".]"
$
$ XDEFINE RUBY_SRCROOT 'srcroot'
$ XDEFINE RUBY_BLDROOT 'bldroot'
$
$ DEFINE STAGE$ RUBY_BLDROOT:[STAGE]
$
$ DEFINE SRC$ RUBY_SRCROOT:[000000], RUBY_SRCROOT:[VMS], RUBY_SRCROOT:[MISSING]
$ DEFINE LIS$ RUBY_BLDROOT:[LIS]
$ DEFINE OBJ$ RUBY_BLDROOT:[OBJ]
$ DEFINE EXE$ RUBY_BLDROOT:[OBJ]
$ DEFINE COM$ RUBY_BLDROOT:[COM],'here'
$ DEFINE KIT$ RUBY_BLDROOT:[KIT]
$ DEFINE TMPSRC$ RUBY_BLDROOT:[TMPSRC]
$ DEFINE STAGE$  RUBY_BLDROOT:[STAGE]
$
$ DEFINE DECC$USER_INCLUDE   SRC$
$ DEFINE DECC$SYSTEM_INCLUDE SRC$
$
$ ! for extended libraries
$ extsrcroot = srcroot - "]" + "EXT.]"
$ XDEFINE EXTSRC$ 'extsrcroot'
$
$ CALL CREDIR LIS$
$ CALL CREDIR OBJ$
$ CALL CREDIR EXE$
$ CALL CREDIR KIT$
$ CALL CREDIR TMPSRC$
$
$ IF P1 .EQS. "" THEN P1 = "CLEANUP"
$ GOTO 'P1'
$
$CLEANUP:
$ CALL DELETEALL LIS$
$ CALL DELETEALL OBJ$
$ CALL DELETEALL EXE$
$ CALL DELETEALL TMPSRC$
$
$MAKE:
$ IF F$TRNLNM("VMSVERSION_H") .NES. "" THEN CLOSE VMSVERSION_H
$ OPEN/WRITE VMSVERSION_H TMPSRC$:VMSVERSION.H
$ WRITE VMSVERSION_H F$FAO("#define RUBY_PLATFORM     ""!AS""", RUBY_PLATFORM)
$ WRITE VMSVERSION_H F$FAO("#define RUBY_SITE_LIB2    ""!AS""", RUBY_SITE_LIB2)
$ WRITE VMSVERSION_H F$FAO("#define RUBY_SITE_ARCHLIB ""!AS""", RUBY_SITE_ARCHLIB)
$ WRITE VMSVERSION_H F$FAO("#define RUBY_SITE_LIB     ""!AS""", RUBY_SITE_LIB)
$ WRITE VMSVERSION_H F$FAO("#define RUBY_LIB          ""!AS""", RUBY_LIB)
$ WRITE VMSVERSION_H F$FAO("#define RUBY_ARCHLIB      ""!AS""", RUBY_ARCHLIB)
$ CLOSE VMSVERSION_H
$
$ IF P2 .NES. "DEBUG"
$ THEN MMS/DESCRIPTION=COM$:RUBY.MMS
$ ELSE MMS/DESCRIPTION=COM$:RUBY.MMS /MACRO="DEBUG=1"
$ ENDIF
$
$LAST_ACTION:
$ GOTO EXIT
$
$EXTLIB:
$ @COM$:BUILD_EXTLIB "" 'P1'
$ GOTO EXIT
$
$BLDLIB:
$ bldlib = F$SEARCH("COM$:BUILD_BLDLIB.COM")
$ IF bldlib .NES. "" THEN @'bldlib'
$ GOTO EXIT
$
$KITGEN:
$ kitgen = F$SEARCH("COM$:BUILD_KITGEN.COM")
$ IF kitgen .NES. "" THEN @'kitgen' 'P2'
$ GOTO EXIT
$
$SETUP:
$ GOTO EXIT
$
$EXIT:
$ EXIT
$
$DELETEALL: SUBROUTINE
$ c = 5698
$ IF F$SEARCH(F$PARSE("*.*;*",P1),c) .NES. "" THEN DELETE 'F$PARSE("*.*;*",P1)'
$ ENDSUBROUTINE
$
$
$CREDIR: SUBROUTINE
$ IF F$PARSE(P1) .EQS. "" THEN CREATE/DIRECTORY/LOG 'P1'
$ ENDSUBROUTINE
