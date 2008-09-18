!
! DESCRIP.MMS - MMS description file for blockio
!
.INCLUDE COM$:EXTLIB_COMMON.MMS

! FixMe: must manually build/copy CLCKLIB.EXE to EXE$:
EXE$:LCKLIB.EXE : -
	OBJ$:LCKLIB.OBJ, -
	EXE$:RUBYSHR.EXE, -
        EXE$:CLCKLIB.EXE
    $(LINK)$(LINKDEBFLAGS)$(LINKSHRFLAGS) -
	OBJ$:LCKLIB.OBJ, -
        EXTSRC$:[LCKLIB]CLCKLIB.OPT/OPTION, -
        EXTSRC$:[LCKLIB]CLCKLIB_VECTOR.OPT/OPTION, -
	EXTSRC$:[LCKLIB]LCKLIB.OPT/OPTION, -
	SRC$:EXTLIB.OPT/OPTION, OBJ$:VERSION.OPT/OPTION

OBJ$:LCKLIB.OBJ : EXTSRC$:[LCKLIB]LCKLIB.C

!
! move to the target directory
!
BLDLIB : 
  COPY EXE$:LCKLIB.EXE $(TARGET)LCKLIB.EXE 

