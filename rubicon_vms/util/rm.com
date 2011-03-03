$ suppress_warning=0
$ p1_len=f$length(p1)
$ set noon
$ if f$locate("-",p1).eq.0
$ then
$   ! p1 contains switches:
$   if f$locate("F",p1).ne.p1_len
$   then
$     suppress_warning=1
$     set message/nofac/noid/nosev/notext
$   endif
$ else
$   ! p1 is an argument:
$   call rm 'p1'
$ endif
$ call rm 'p2'
$ call rm 'p3'
$ call rm 'p4'
$ call rm 'p5'
$ call rm 'p6'
$ call rm 'p7'
$ call rm 'p8'
$ set on
$ if suppress_warning then set message/fac/id/sev/text
$ exit
$ rm: subroutine
$ if p1.nes."" then delete 'p1';*
$ endsubroutine
