objs=Dir['*.obj'].join(',')
link_flags="/shareable=ferret_ext.exe #{objs},ferret.opt/options"

args=ARGV.join(' ')
if(args =~ /\/debug/i)
   link_flags="/debug"+link_flags
   args.sub!(/\/debug/,'')
end

cmd="link #{link_flags}"
puts cmd
puts `#{cmd}`
