$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestSymbol < Rubicon::TestCase

# v---------- test --------------v
  class Fred
    $f1 = :Fred
    def Fred
      $f3 = :Fred
    end
  end
  
  module Test
    Fred = 1
    $f2 = :Fred
  end
  
# ^----------- test ------------^

  Fred.new.Fred

  def test_00sanity
    assert_equal($f1.__id__,$f2.__id__)
    assert_equal($f2.__id__,$f3.__id__)
  end

  def test_id2name
    assert_equal("Fred",:Fred.id2name)
    assert_equal("Barney",:Barney.id2name)
    assert_equal("wilma",:wilma.id2name)
  end

  def test_to_i
    assert_equal($f1.to_i,$f2.to_i)
    assert_equal($f2.to_i,$f3.to_i)
    assert(:wilma.to_i != :Fred.to_i)
    assert(:Barney.to_i != :wilma.to_i)
  end

  def test_to_s
    assert_equal("Fred",:Fred.id2name)
    assert_equal("Barney",:Barney.id2name)
    assert_equal("wilma",:wilma.id2name)
  end

  def test_type
    assert_equal(Symbol, :Fred.class)
    assert_equal(Symbol, :fubar.class)
  end

  def test_taint
    assert_same(:Fred, :Fred.taint)
    assert(! :Fred.tainted?)
  end

  def test_freeze
    assert_same(:Fred, :Fred.freeze)
    assert(! :Fred.frozen?)
  end

  def test_dup
    assert_raise(TypeError) { :Fred.clone }
    assert_raise(TypeError) { :Fred.dup }
  end
end

Rubicon::handleTests(TestSymbol) if $0 == __FILE__
