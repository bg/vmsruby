$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

class TestSymbols < Rubicon::TestCase

end

# Run these tests if invoked directly

Rubicon::handleTests(TestSymbols) if $0 == __FILE__
