$ self=f$environment("procedure")
$ checkstat=="$"+f$parse("[.util]checkstat.exe;",self)
$ test_touch=="$"+f$parse("[.util]test_touch.exe;",self)
$ rm=="@"+f$parse("[.util]rm.com;",self)
