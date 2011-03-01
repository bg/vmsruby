$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestFalseClass < Rubicon::TestCase

  def test_00_sanity
    assert_equal(false, FALSE)
  end

  def test_AND # '&'
    truth_table(false.method("&"), false, false)
  end

  def test_OR # '|'
    truth_table(false.method("|"), false, true)
  end

  def test_XOR # '^'
    truth_table(false.method("^"), false, true)
  end

  def test_to_s
    assert_equal("false", false.to_s)
    assert_equal("false", FALSE.to_s)
  end

  def test_type
    assert_equal(FalseClass, false.class)
    assert_equal(FalseClass, FALSE.class)
  end

end

Rubicon::handleTests(TestFalseClass) if $0 == __FILE__
