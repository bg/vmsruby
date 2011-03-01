$: << File.dirname($0) << File.join(File.dirname($0), "..")

require 'rubicon'
require 'StringBase'


class TestString < StringBase

  def initialize(*args)
    @cls = String
    super
  end

end

Rubicon::handleTests(TestString) if $0 == __FILE__
