$ define ruby_bldroot dsa1:[dymax.misc.ruby018_snapshot.vmsbuild.]/trans=conc
$ define exe$ ruby_bldroot:[obj]
$ define rubyshr exe$:rubyshr.exe
$ ruby == "$exe$:ruby_interpreter.exe"
$ echo "[ ruby == <ruby 1.8.2 in build dir>; type @dyulib:rbylog to revert ]"
