$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestObject < Rubicon::TestCase
  class TestClass
    attr_accessor :var1
  end
  
  def setup
    @test_class = TestClass.new
  end
  
  def test_instance_variable_get
    @test_class.var1 = "c"
    assert_equal("c", @test_class.instance_variable_get("@var1"))
    @test_class.var1 = "d"
    assert_equal("d", @test_class.instance_variable_get(:@var1))
    assert_raises(NameError) { @test_class.instance_variable_get("var1") }
    assert_raises(NameError) { @test_class.instance_variable_get(:var1) }
    assert_nil(@test_class.instance_variable_get(:@var2))
  end
  
  def test_instance_variable_set
    assert_equal("a", @test_class.instance_variable_set("@var1", "a"))
    assert_equal("a", @test_class.var1)
    assert_equal("b", @test_class.instance_variable_set(:@var1, "b"))
    assert_equal("b", @test_class.var1)
    assert_raises(NameError) { @test_class.instance_variable_set("var1", "x") }
    assert_raises(NameError) { @test_class.instance_variable_set(:var1, "x") }
  end
end

Rubicon::handleTests(TestObject) if $0 == __FILE__
