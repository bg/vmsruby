$set noon
$define sys$output build_ruby_with_log.2dq
$set ver
$echo ""
$ECHO "[ STEP 1 - @BUILD ]"
$echo ""
$@build
$to [-.-.ruby.ext.lcklib]
$echo ""
$ECHO "[ STEP 2 - @BUILD_CLCKLIB ]"
$echo ""
$@build_clcklib
$copy clcklib.exe exe$:
$define clcklib exe$:clcklib.exe
$to [-.-.-.vmsbuild.com]
$echo ""
$ECHO "[ STEP 3 - @BUILD EXTLIB ]"
$echo ""
$@build extlib
$create/dir [-.stage.ruby.lib.018.alpha-vms.digest]
$create/dir [-.stage.ruby.lib.018.ia64-vms.digest]
$echo ""
$ECHO "[ STEP 4 - @BUILD BLDLIB ]"
$echo ""
$@build bldlib
$echo ""
$ECHO "[ STEP 5 - @BUILD KITGEN ]"
$echo ""
$@build kitgen
$deassign sys$output
$set on
