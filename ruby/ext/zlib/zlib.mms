!
! DESCRIP.MMS - MMS description file for zlib
!
.INCLUDE COM$:EXTLIB_COMMON.MMS
USER_CFLAGS = /INCLUDE_DIRECTORY=(SYS$COMMON:[LIBZ])


EXE$:ZLIB.EXE : -
	OBJ$:ZLIB.OBJ, -
	EXE$:RUBYSHR.EXE
    $(LINK)$(LINKDEBFLAGS)$(LINKSHRFLAGS) -
	OBJ$:ZLIB.OBJ, -
	EXTSRC$:[ZLIB]ZLIB.OPT/OPTION, -
	SRC$:EXTLIB.OPT/OPTION, OBJ$:VERSION.OPT/OPTION

OBJ$:ZLIB.OBJ : EXTSRC$:[ZLIB]ZLIB.C

!
! move to the target directory
!
BLDLIB : 
  COPY EXE$:ZLIB.EXE $(TARGET)ZLIB.EXE 

