!
! ruby_ia64.mms -- MMS Description File to Bulild Ruby for VMS
!
! This is a copy of ruby.mms with the following changes:
!
!    The following modules are omitted:
!	- LNK
!	- UTIME
!	- CRYPT
!

.SUFFIXES
.SUFFIXES .EXE,.OLB,.OBJ,.C,.H,.Y

.C.OBJ
    COPY $(MMS$SOURCE) TMPSRC$:'F$PARSE("$(MMS$SOURCE)",,,"NAME")'
    $(CC)$(CFLAGS) TMPSRC$:'F$PARSE("$(MMS$SOURCE)",,,"NAME")'
!    DELETE TMPSRC$:'F$PARSE("$(MMS$SOURCE)",,,"NAME")'.C;
.Y.C
    COPY $(MMS$SOURCE) TMPSRC$:'F$PARSE("$(MMS$SOURCE)",,,"NAME")'
    BISON$(BISONFLAGS) TMPSRC$:'F$PARSE("$(MMS$SOURCE)",,,"NAME")'.Y
!    DELETE TMPSRC$:'F$PARSE("$(MMS$SOURCE)",,,"NAME")'.Y;

.IFDEF DEBUG
CDEBFLAGS=/DEBUG/NOOPTIMIZE
LINKDEBFLAGS=/DEBUG
.ENDIF

CFLAGS =-
$(CDEBFLAGS)-
/OBJECT=$(MMS$TARGET)/LIST=LIS$:$(MMS$SOURCE_NAME).LIS-
/STANDARD=RELAXED_ANSI89/PREFIX=EXCEPT=(vsnprintf,snprintf,gai_strerror)-
/DEFINE=(__FAST_SETJMP)-
/NAME=(UPPERCASE,SHORTENED)-
/REPOSITORY=OBJ$-
/ACCEPT=GCCINLINE/SHOW=ALL-
/FLOATING=IEEE/IEEE_MODE=INEXACT-
/WARNINGS=(INFORMATIONAL=ALL)-

BISONFLAGS =-
/OUTPUT=$(MMS$TARGET) 

LINKSHRFLAGS=-
/SHAREABLE=$(MMS$TARGET)/MAP=LIS$:'F$PARSE("$(MMS$TARGET)",,,"NAME")'.MAP/CROSS/FULL

LINKEXEFLAGS=-
/EXECUTABLE=$(MMS$TARGET)/MAP=LIS$:'F$PARSE("$(MMS$TARGET)",,,"NAME")'.MAP/CROSS/FULL

LINKMINIFLAGS=$(LINKEXEFLAGS)

ruby_modules = -
    MAIN=OBJ$:MAIN.OBJ, -
    ARRAY=OBJ$:ARRAY.OBJ, -
    BIGNUM=OBJ$:BIGNUM.OBJ, - 
    CLASS=OBJ$:CLASS.OBJ, - 
    COMPAR=OBJ$:COMPAR.OBJ, - 
    DIR=OBJ$:DIR.OBJ, - 
    DLN=OBJ$:DLN.OBJ, - 
    DMYEXT=OBJ$:DMYEXT.OBJ, - 
    ENUM=OBJ$:ENUM.OBJ, - 
    ERROR=OBJ$:ERROR.OBJ, - 
    EVAL=OBJ$:EVAL.OBJ, -
    FILE=OBJ$:FILE.OBJ, - 
    GC=OBJ$:GC.OBJ, - 
    HASH=OBJ$:HASH.OBJ, - 
    INITS=OBJ$:INITS.OBJ, - 
    IO=OBJ$:IO.OBJ, -
    MARSHAL=OBJ$:MARSHAL.OBJ, -
    MATH=OBJ$:MATH.OBJ, -
    NUMERIC=OBJ$:NUMERIC.OBJ, -
    OBJECT=OBJ$:OBJECT.OBJ, -
    PACK=OBJ$:PACK.OBJ, -
    PREC=OBJ$:PREC.OBJ, -
    PROCESS=OBJ$:PROCESS.OBJ, -
    RANDOM=OBJ$:RANDOM.OBJ, -
    RANGE=OBJ$:RANGE.OBJ, -
    RE=OBJ$:RE.OBJ, -
    REGEX=OBJ$:REGEX.OBJ, -
    RUBY=OBJ$:RUBY.OBJ, -
    SIGNAL=OBJ$:SIGNAL.OBJ, -
    SPRINTF=OBJ$:SPRINTF.OBJ, -
    ST=OBJ$:ST.OBJ, -
    STRING=OBJ$:STRING.OBJ, -
    STRUCT=OBJ$:STRUCT.OBJ, -
    TIME=OBJ$:TIME.OBJ, -
    UTIL=OBJ$:UTIL.OBJ, -
    VARIABLE=OBJ$:VARIABLE.OBJ, -
    VERSION=OBJ$:VERSION.OBJ, -
    FLOCK=OBJ$:FLOCK.OBJ, - 
    ISINF=OBJ$:ISINF.OBJ, - 
    VSNPRINTF=OBJ$:VSNPRINTF.OBJ, -
    PARSE=OBJ$:PARSE.OBJ,-
    VMSRUBY_PRIVATE=OBJ$:VMSRUBY_PRIVATE.OBJ -
    REDIR=OBJ$:REDIR.OBJ,-
    VMS=OBJ$:VMS.OBJ

module=$(ruby_modules)

OBJLIB = OBJ$:OBJLIB.OLB
SHRLIB = EXE$:RUBYSHR.EXE

.FIRST
        @COM$:COPY_HEADER_FILES.COM VERIFY
        @COM$:COPY_HEADER_FILES.COM VERIFY SRC$:LEX.C

EXE$:RUBY_INTERPRETER.EXE : $(OBJLIB),$(SHRLIB),SRC$:RUBY.OPT,OBJ$:VERSION.OPT
	$(LINK)$(LINKDEBFLAGS)$(LINKEXEFLAGS) $(OBJLIB)/INCLUDE=MAIN,SRC$:RUBY.OPT/OPTION,OBJ$:VERSION.OPT/OPTION

EXE$:RUBYSHR.EXE : $(OBJLIB)($(module)),SRC$:RUBYSHR.OPT,OBJ$:VERSION.OPT
	$(LINK)$(LINKDEBFLAGS)$(LINKSHRFLAGS) $(OBJLIB)/LIBRARY,SRC$:RUBYSHR.OPT/OPTION,OBJ$:VERSION.OPT/OPTION

EXE$:MINIRUBY.EXE : $(OBJLIB)($(module))
	$(LINK)$(LINKMINIFLAGS)  $(OBJLIB)/INCLUDE=MAIN,$(OBJLIB)/LIBRARY

OBJ$:VERSION.OPT : COM$:VERSION.RB, EXE$:MINIRUBY.EXE
	MINIRUBY := $EXE$:MINIRUBY.EXE
	MINIRUBY COM$:VERSION.RB

OBJ$:OBJLIB.OLB :
	LIBRARY/OBJECT/CREATE $(MMS$TARGET)

OBJ$:MAIN.OBJ		: SRC$:MAIN.C
OBJ$:ARRAY.OBJ		: SRC$:ARRAY.C
OBJ$:BIGNUM.OBJ		: SRC$:BIGNUM.C
OBJ$:CLASS.OBJ		: SRC$:CLASS.C
OBJ$:COMPAR.OBJ		: SRC$:COMPAR.C
OBJ$:DIR.OBJ		: SRC$:DIR.C
OBJ$:DLN.OBJ		: SRC$:DLN.C
OBJ$:DMYEXT.OBJ		: SRC$:DMYEXT.C
OBJ$:ENUM.OBJ		: SRC$:ENUM.C
OBJ$:ERROR.OBJ		: SRC$:ERROR.C
OBJ$:EVAL.OBJ		: SRC$:EVAL.C
OBJ$:FILE.OBJ		: SRC$:FILE.C
OBJ$:GC.OBJ		: SRC$:GC.C
OBJ$:HASH.OBJ		: SRC$:HASH.C
OBJ$:INITS.OBJ		: SRC$:INITS.C
OBJ$:IO.OBJ		: SRC$:IO.C
OBJ$:MARSHAL.OBJ	: SRC$:MARSHAL.C
OBJ$:MATH.OBJ		: SRC$:MATH.C
OBJ$:NUMERIC.OBJ	: SRC$:NUMERIC.C
OBJ$:OBJECT.OBJ		: SRC$:OBJECT.C
OBJ$:PACK.OBJ		: SRC$:PACK.C
OBJ$:PREC.OBJ		: SRC$:PREC.C
OBJ$:PROCESS.OBJ	: SRC$:PROCESS.C
OBJ$:RANDOM.OBJ		: SRC$:RANDOM.C
OBJ$:RANGE.OBJ		: SRC$:RANGE.C
OBJ$:RE.OBJ		: SRC$:RE.C
OBJ$:REGEX.OBJ		: SRC$:REGEX.C
OBJ$:RUBY.OBJ		: SRC$:RUBY.C
OBJ$:SIGNAL.OBJ		: SRC$:SIGNAL.C
OBJ$:SPRINTF.OBJ	: SRC$:SPRINTF.C
OBJ$:ST.OBJ		: SRC$:ST.C
OBJ$:STRING.OBJ		: SRC$:STRING.C
OBJ$:STRUCT.OBJ		: SRC$:STRUCT.C
OBJ$:TIME.OBJ		: SRC$:TIME.C
OBJ$:UTIL.OBJ		: SRC$:UTIL.C
OBJ$:VARIABLE.OBJ	: SRC$:VARIABLE.C

OBJ$:VERSION.OBJ	: SRC$:VERSION.C

OBJ$:FLOCK.OBJ		: SRC$:FLOCK.C
OBJ$:ISINF.OBJ		: SRC$:ISINF.C
OBJ$:VSNPRINTF.OBJ	: SRC$:VSNPRINTF.C

OBJ$:PARSE.OBJ		: OBJ$:PARSE.C
OBJ$:PARSE.C		: SRC$:PARSE.Y

OBJ$:VMSRUBY_PRIVATE.OBJ : SRC$:VMSRUBY_PRIVATE.C

OBJ$:REDIR.OBJ		: SRC$:REDIR.C
OBJ$:VMS.OBJ		: SRC$:VMS.C
