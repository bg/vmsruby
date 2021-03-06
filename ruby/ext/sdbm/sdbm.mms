!
! DESCRIP.MMS - MMS description file for SDBM
!
.INCLUDE COM$:EXTLIB_COMMON.MMS

.FIRST
    DEFINE/NOLOG DECC$USER_INCLUDE EXTSRC$:[SDBM]

EXE$:SDBM.EXE : -
	OBJ$:INIT.OBJ, OBJ$:_SDBM.OBJ, -
	EXE$:RUBYSHR.EXE
    $(LINK)$(LINKDEBFLAGS)$(LINKSHRFLAGS) -
	OBJ$:INIT.OBJ, OBJ$:_SDBM.OBJ, -
	EXTSRC$:[SDBM]SDBM.OPT/OPTION, SRC$:EXTLIB.OPT/OPTION, OBJ$:VERSION.OPT/OPTION

OBJ$:INIT.OBJ      : EXTSRC$:[SDBM]INIT.C
OBJ$:_SDBM.OBJ     : EXTSRC$:[SDBM]_SDBM.C

!
! move to the target directory 
!
BLDLIB :
    COPY EXE$:SDBM.EXE $(TARGET)SDBM.EXE 
