$ LIBRARY/REPLACE OBJ$:OBJLIB.OLB OBJ$:IO.OBJ
$ LINK/EXECUTABLE=EXE$:MINIRUBY.EXE -
  /MAP=LIS$:'F$PARSE("EXE$:MINIRUBY.EXE",,,"NAME")'.MAP-
  OBJ$:OBJLIB.OLB/INCLUDE=MAIN,OBJ$:OBJLIB.OLB/LIBRARY
$ MINIRUBY := $EXE$:MINIRUBY.EXE
$ MINIRUBY COM$:VERSION.RB
$ LINK/SHAREABLE=EXE$:RUBYSHR.EXE -
  /MAP=LIS$:'F$PARSE("EXE$:RUBYSHR.EXE",,,"NAME")'.MAP-
  OBJ$:OBJLIB.OLB/LIBRARY,SRC$:RUBYSHR.OPT/OPTION,OBJ$:VERSION.OPT/OPTION
$ LINK/EXECUTABLE=EXE$:RUBY_INTERPRETER.EXE -
  /MAP=LIS$:'F$PARSE("EXE$:RUBY_INTERPRETER.EXE",,,"NAME")'.MAP -
  OBJ$:OBJLIB.OLB/INCLUDE=MAIN,SRC$:RUBY.OPT/OPTION,OBJ$:VERSION.OPT/OPTION
