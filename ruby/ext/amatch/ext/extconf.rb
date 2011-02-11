#
## $Id: extconf.rb,v 1.3 2005/11/10 05:06:26 flori Exp $
#

require 'mkmf'
require 'rbconfig'
if CONFIG['CC'] == 'gcc'
  CONFIG['CC'] = 'gcc -Wall '
end
create_makefile 'amatch' 
  # vim: set et sw=2 ts=2:
