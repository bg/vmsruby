$: << File.dirname($0) << File.join(File.dirname($0), "..")

require 'rubicon'
require 'ArrayBase.rb'


class TestArray < ArrayBase
  def initialize(*args)
    @cls = Array
    super
  end
end



Rubicon::handleTests(TestArray) if $0 == __FILE__
