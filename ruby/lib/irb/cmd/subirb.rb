#!/usr/local/bin/ruby
#
#   multi.rb - 
#   	$Release Version: 0.9$
#   	$Revision: 1.1 $
#   	$Date: 2002/07/09 11:17:17 $
#   	by Keiju ISHITSUKA(Nihon Rational Software Co.,Ltd)
#
# --
#
#   
#

require "irb/cmd/nop.rb"
require "irb/ext/multi-irb"

module IRB
  module ExtendCommand
    class IrbCommand<Nop
      def execute(*obj)
	IRB.irb(nil, *obj)
      end
    end

    class Jobs<Nop
      def execute
	IRB.JobManager
      end
    end

    class Foreground<Nop
      def execute(key)
	IRB.JobManager.switch(key)
      end
    end

    class Kill<Nop
      def execute(*keys)
	IRB.JobManager.kill(*keys)
      end
    end
  end
end
