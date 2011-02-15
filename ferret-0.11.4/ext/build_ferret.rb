
STATUS_NORMAL="%X00000001"

def exit_on_error(cmd_name='')
   if( ENV['$STATUS'] != "%X00000001" )
      puts "#{cmd_name}: terminated in error, exiting."
      exit
   end
end

cmd_out=`ruby compile_ferret.rb`
puts cmd_out
exit_on_error()
cmd_out=`ruby link_ferret.rb`
puts cmd_out
exit_on_error()
cmd_out=`copy []ferret_ext.exe [dymax.pro.ruby.lib.site_ruby.alpha-vms]`
puts cmd_out

