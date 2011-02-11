$ @dyulib:rbylog build
$ copy rdl:*.rb ruby_bldroot:[stage.ruby.lib.site_ruby.dylib]
$! copy ruby_root:[lib.018.alpha-vms]socket.exe ruby_bldroot:[stage.ruby.lib.018.alpha-vms]
$ copy ruby_root:[prog]*. ruby_bin:
