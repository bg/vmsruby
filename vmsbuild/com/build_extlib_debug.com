$! P1 - extlib		(ex. SOCKET, NKF...)
$! P2 - phase		(ex. EXTLIB, BLDLIB...)
$! P3 - target		(target for extended libraries)
$! P4 - library root	(target for .rb files)
$
$ @BUILD SETUP
$
$ makeflag = ""
$
$ extlib  = P1
$ phase   = P2
$ target  = P3
$ libroot = P4
$
$ IF phase  .EQS. "" THEN phase  := CLEANUP
$ IF target .EQS. "" THEN target := nosuchdev:[nosuchdir]
$ IF extlib .NES. "" THEN GOTO BUILD_ONE
$
$!
$! Build all extension libraries
$!
$BUILD_ALL:
$! CALL BUILD SOCKET		'phase' 'target' 'libroot'
$ CALL BUILD NKF		'phase' 'target' 'libroot'
$ CALL BUILD DIGEST 		'phase' 'target' 'libroot'
$ CALL BUILD DIGEST.MD5		'phase' 'target' 'libroot'
$ CALL BUILD DIGEST.SHA1	'phase' 'target' 'libroot'
$ CALL BUILD DIGEST.SHA2	'phase' 'target' 'libroot'
$ CALL BUILD SDBM		'phase' 'target' 'libroot'
$ CALL BUILD FCNTL		'phase' 'target'
$! CALL BUILD DL			'phase' 'target' 'libroot'
$ CALL BUILD STRINGIO		'phase' 'target' 'libroot'
$ CALL BUILD STRSCAN		'phase' 'target' 'libroot'
$ CALL BUILD SYCK		'phase' 'target' 'libroot'
$ CALL BUILD ZLIB		'phase' 'target' 'libroot'
$! CALL BUILD LCKLIB		'phase' 'target' 'libroot'
$ CALL BUILD OPENSSL		'phase' 'target' 'libroot'
$ EXIT
$
$!
$! Build an extension extlib
$!
$BUILD_ONE:
$ CALL BUILD 'extlib' 'phase' 'target' 'libroot'
$ EXIT
$
$!
$!
$!
$BUILD: SUBROUTINE
$ extlib  = P1
$ phase   = P2
$ target  = P3
$ libroot = P4
$
$ libname = ""
$ libpath = ""
$ i = 0
$ LIBPATHLOOP:
$   s = F$ELEMENT(i, ".", extlib)
$   IF s .EQS. "."   THEN GOTO EXIT_LIBPATHLOOP
$   IF libpath .NES. "" THEN libpath + libpath + "."
$   libpath = libpath + libname
$   libname = s
$   i = i + 1
$ GOTO LIBPATHLOOP
$ EXIT_LIBPATHLOOP:
$ IF libpath .NES. "" THEN target = target + "[.''libpath']" - "]["
$ GOTO 'phase'
$
$CLEANUP:
$ makeflag = "/FROM"
$
$MAKE:
$EXTLIB:
$ MMS'makeflag'/DESCRIPTION=EXTSRC$:['extlib']'libname'.MMS EXE$:'libname'.EXE -
     /MACRO=(DEBUG="1")
$ EXIT
$
$BLDLIB:
$ MMS/DESCRIPTION=EXTSRC$:['extlib']'libname.MMS BLDLIB -
     /MACRO=(TARGET="''target'", LIBROOT="''libroot'")
$ EXIT
$
$ ENDSUBROUTINE
