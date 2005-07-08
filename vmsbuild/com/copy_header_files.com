$ vvvv = 'F$VERIFY(0)'
$
$ VERIFY   = P1 .EQS. "VERIFY"
$
$ IF P2 .EQS. ""
$ THEN FILESPEC = "SRC$:*.H"
$ ELSE FILESPEC = P2
$ ENDIF
$
$ wildcard = "FALSE"
$ wildcard = wildcard .OR. (F$LOCATE("*",FILESPEC) .LT. F$LENGTH(FILESPEC))
$ wildcard = wildcard .OR. (F$LOCATE("%",FILESPEC) .LT. F$LENGTH(FILESPEC))
$
$ LOOP:
$   source = F$SEARCH(FILESPEC,1)
$   IF source .EQS. "" THEN GOTO EXIT_LOOP
$   name = F$PARSE(source,,,"NAME") + F$PARSE(source,,,"TYPE")
$   target = "TMPSRC$:''name'"
$   sdate = F$CVTIME(F$FILE(source,"RDT"))
$   IF F$SEARCH(target,2) .NES. ""
$   THEN tdate = F$CVTIME(F$FILE(target,"RDT"))
$   ELSE tdate = "0000-00-00 00:00:00.00"
$   ENDIF
$   IF tdate .LES. sdate
$   THEN 
$     COPY 'source' 'target';
$     IF VERIFY THEN WRITE SYS$OUTPUT "COPY ''source' ''target'"
$   ENDIF
$ IF wildcard THEN GOTO LOOP
$ EXIT_LOOP:
$
$ EXIT 1 + 0 * F$VERIFY(vvvv)
