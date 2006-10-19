$ @dyulib:newdir [dymax.misc.rubyw.bin] dsa1:
$ @dyulib:newdir [dymax.misc.rubyw.lib.018.alpha-vms.digest] dsa1:
$ copy/log [.obj]rubyshr.exe [dymax.misc.rubyw.bin]
$ copy/log [.obj]ruby_interpreter.exe [dymax.misc.rubyw.bin]ruby.exe
$ copy/log [.stage.ruby.lib.018.alpha-vms]*.exe [dymax.misc.rubyw.lib.018.alpha-vms]
$ copy/log [.stage.ruby.lib.018.alpha-vms.digest]*.exe [dymax.misc.rubyw.lib.018.alpha-vms.digest]
