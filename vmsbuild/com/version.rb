ruby_version_vms =  RUBY_VERSION.sub(/([0-9]+).([0-9]+).([0-9]+)/, 'V\1.\2-\3')

system("DEFINE/JOB/NOLOG RUBY_MAKING_VERSION \"" + ruby_version_vms + "\"")

file = open("OBJ$:VERSION.OPT","w")
file.print("IDENTIFICATION=\"Ruby " + ruby_version_vms + "\"")
file.close
