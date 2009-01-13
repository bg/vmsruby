$ source_disk       = "dsa1:"
$ source_parent_dir = "[dymax.misc.ruby018_snapshot.vmsbuild]"
$ source_parent     = source_disk+source_parent_dir
$ source_root       = source_parent-"]"
$!
$ target_disk		= "dym$disk:"
$ target_parent_dir	= "[dymax.pro]"
$ target_parent		= target_disk+target_parent_dir
$ target_root_dir	= target_parent_dir-"]"+".ruby_new"
$ target_root		= target_disk+target_root_dir
$!
$ @dyulib:newdir 'target_root_dir']         'target_disk'
$ @dyulib:newdir 'target_root_dir'.include] 'target_disk'
$ @dyulib:newdir 'target_root_dir'.prog]    'target_disk'
$ @dyulib:newdir 'target_root_dir'.src]     'target_disk'
$!
$ backup/log 'source_root'.stage.ruby.lib...] -
                                            'target_root'.lib...]*.*
$! FixMe: ideally, we should populate the stage directory first with
$!        these files/directories via build.com.
$ backup/log 'source_root'.obj]rubyshr.exe  'target_root'.prog]*.*
$ backup/log 'source_root'.obj]ruby_interpreter.exe -
                                            'target_root'.prog]ruby.exe
$ backup/log 'source_root'.obj]*.           'target_root'.prog]*.
$ backup/log 'source_root'.tmpsrc]*.h       'target_root'.include]*.*
$ backup/log 'source_root'.-.test...]*.*    'target_root'.test...]*.*
$ backup/log 'source_root'.-.ruby...]*.*    'target_root'.src.ruby...]*.*
$ set file/prot=(s:rwed,o:rwed,g:rwed,w:re) 'target_root'...]*.*;
$ set file/prot=(s:rwed,o:rwed,g:rwed,w:re) 'target_parent'ruby_new.dir;
$! TODO: ruby_dylib & other site_ruby?
$!
$! rename 'target_parent'ruby.dir           ruby_old.dir
$! rename 'target_parent'ruby_new.dir       ruby.dir
