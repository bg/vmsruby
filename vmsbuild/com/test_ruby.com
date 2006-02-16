$ @dyulib:rbylog.new
$ define/trans=conc ruby_root dsa1:[dymax.misc.rubyw.]
$ ruby == "$ruby_bin:ruby.exe"
$ echo "[ ruby == <test ruby 1.8.2>; type @dyulib:rbylog to revert ]"
