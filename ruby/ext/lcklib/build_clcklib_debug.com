$! FixMe: This build procedure is quite specific to the Dymaxion development
$!   environment and has not been packaged to build correctly on other
$!   sites, as we do not distribute the clcklib code.  Find some place
$!   outside of [.ruby.ext] to put our own extensions.
$ perl dyulib:cxxpre.prl rl_vms_libw:lcklib.cpp > lcklib_cpp.pre
$ perl dyulib:cxxpre.prl rl_vms_libw:clcklib.cpp > clcklib_c.pre
$
$ @dyulib:cpuswt.cor
$OLD_SYS_LIBRARY=F$TRNLNM("SYS$LIBRARY")
$!DEFINE SYS$LIBRARY DYLIBS,'OLD_SYS_LIBRARY'
$!Only use .TLB & .OLB from current release:
$DEFINE SYS$LIBRARY DYLIBS,DYM$DISK:[DYMAX.DYLIBS.83STATIC]
$DEFINE ALPHA$LIBRARY DYLIBS
$
$ echo "[ cxx''switches_cxx'/share_globals lcklib_cpp.pre ]"
$ cxx'switches_cxx'/share_globals/debug/noopt lcklib_cpp.pre
$ 
$ echo "[ cxx''switches_cxx'/share_globals clcklib_c.pre ]"
$ cxx'switches_cxx'/share_globals/debug/noopt clcklib_c.pre
$
$ echo "[ Building clcklib_debug.exe ]"
$ cxxlink/gst/shareable=clcklib.exe clcklib_c.obj,lcklib_cpp.obj,clcklib_vector.opt/opt/debug
$
$! del clcklib_c.pre;
$! del lcklib_cpp.pre;
$
$ xd clcklib.exe
$
$ echo "[ Building test t_clcklib.exe ]"
$ perl dyulib:cxxpre.prl t_clcklib.c > t_clcklib_c.pre
$ echo "[ cc/float=D_FLOAT/include=(""[DYMAX.WIP.RL.LIB.SRC.CPP]"") t_clcklib_c.pre ]"
$ cc/float=D_FLOAT/include=("[DYMAX.WIP.RL.LIB.SRC.CPP]") t_clcklib_c.pre
$
$ define/user clcklib 'f$parse("clcklib.exe.",f$environment("procedure"))'
$ link/executable=t_clcklib.exe t_clcklib_c.obj,clcklib.opt/opt
$ xd t_clcklib.exe
$
$ echo "[ Testing t_clcklib.exe ]"
$ copy dbgtext_orig.txt dbgtext.txt
$ define/user clcklib 'f$parse("clcklib.exe.",f$environment("procedure"))'
$ run t_clcklib.exe
$
$DEASSIGN SYS$LIBRARY
$DEASSIGN ALPHA$LIBRARY
