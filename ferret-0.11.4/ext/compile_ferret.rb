compile_flags="/noopt/include_directory=(dsa1:[dymax.misc.ruby018_snapshot.ruby],"+
              "dsa1:[dymax.misc.ruby018_snapshot.ruby.vms],"+
              "[dymax.wip.ferret.inc],[])"+
              "/accept=gccinline/name=shortened/float=ieee/ieee=inexact"

args=ARGV.join(' ')

if args =~ /\/debug/i
   compile_flags="/debug"+compile_flags
   args.sub!(/\/debug/,'')
end

retval=''
if(ARGV[0].nil?)
   Dir['*.c'].each {|src| 
      print "#{src}: "
      cf=compile_flags
      retval= `cc#{cf} #{src}`
      if(retval.length()==0) 
         puts "ok\n"
      else
         puts "\n#{retval}"
      end
   }
else
   print "#{ARGV[0]}: "
   retval= `cc#{compile_flags} #{ARGV[0]}`

   if(retval.length()==0) 
      puts "ok\n"
   else
      puts "\n#{retval}"
   end
end
