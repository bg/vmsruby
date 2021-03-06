$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestRange < Rubicon::TestCase

  def test_EQUAL # '=='
    generic_test_EQUAL(:==)
  end

  #
  # Tests where the methods == and eql? behave the same.
  # This is true when the class of the endpoints of
  # the Range have == and eql? methods that are
  # aliases. This in turn is true for most classes,
  # for example for the class used here: Fixnum.
  #
  # TODO: write tests using an endpoint class where
  # the methods  == and eql? differ.
  #
  def generic_test_EQUAL(method)
    # closed interval
    assert_equal(false, ((3..5).send(method, 3..4)))
    assert_equal(true,  ((3..5).send(method, 3..5)))
    assert_equal(false, ((3..5).send(method, 3..6)))

    assert_equal(false, ((3..5).send(method, 2..5)))
    assert_equal(false, ((3..5).send(method, 4..5)))

    # half-open interval
    assert_equal(false, ((3...5).send(method, 3...4)))
    assert_equal(true,  ((3...5).send(method, 3...5)))
    assert_equal(false, ((3...5).send(method, 3...6)))

    assert_equal(false, ((3...5).send(method, 2...5)))
    assert_equal(false, ((3...5).send(method, 4...5)))

    # half-open / closed interval: never equal
    assert_equal(false, ((3...5).send(method, 3..4)))
    assert_equal(false, ((3...5).send(method, 3..5)))
    assert_equal(false, ((3...5).send(method, 3..6)))

    assert_equal(false, ((3...5).send(method, 2..5)))
    assert_equal(false, ((3...5).send(method, 4..5)))

    # closed / half-open interval: never equal
    assert_equal(false, ((3..5).send(method, 3...4)))
    assert_equal(false, ((3..5).send(method, 3...5)))
    assert_equal(false, ((3..5).send(method, 3...6)))

    assert_equal(false, ((3..5).send(method, 2...5)))
    assert_equal(false, ((3..5).send(method, 4...5)))

    # non-Range argument
    assert_equal(false, ((5..10).send(method, Object.new)))
    assert_equal(false, ((5...10).send(method, Object.new)))

  end

  def test_VERY_EQUAL # '==='
    # closed interval
    assert_equal(false, ((5..10) === 4))
    assert_equal(true,  ((5..10) === 5))
    assert_equal(true,  ((5..10) === 6))
    assert_equal(true,  ((5..10) === 9))
    assert_equal(true,  ((5..10) === 10))
    assert_equal(false, ((5..10) === 11))

    assert_equal(false, ((5..10) === 4.5))
    assert_equal(true,  ((5..10) === 5.5))
    assert_equal(true,  ((5..10) === 7.5))
    assert_equal(true,  ((5..10) === 9.5))
    assert_equal(false, ((5..10) === 10.5))

    # half-open interval
    assert_equal(false, ((5...10) === 4))
    assert_equal(true,  ((5...10) === 5))
    assert_equal(true,  ((5...10) === 6))
    assert_equal(true,  ((5...10) === 9))
    assert_equal(false, ((5...10) === 10))
    assert_equal(false, ((5...10) === 11))

    assert_equal(false, ((5...10) === 4.5))
    assert_equal(true,  ((5...10) === 5.5))
    assert_equal(true,  ((5...10) === 7.5))
    assert_equal(true,  ((5...10) === 9.5))
    assert_equal(false, ((5...10) === 10.5))

    # non-comparable argument
    assert_equal(false, ((5..10)  === Object.new))
    assert_equal(false, ((5...10) === Object.new))

    # misc
    gotit = false
    case 52
      when 0..49
        fail("Shouldn't have matched")
      when 50..75
        gotit = true
      else
        fail("Shouldn't have matched")
    end
    assert_equal(true,gotit)

    gotit = false
    case 50
      when 0..49
        fail("Shouldn't have matched")
      when 50..75
        gotit = true
      else
        fail("Shouldn't have matched")
    end
    assert_equal(true,gotit)

    gotit = false
    case 75
      when 0..49
        fail("Shouldn't have matched")
      when 50..75
        gotit = true
      else
        fail("Shouldn't have matched")
    end
    assert_equal(true,gotit)
  end

  def test_begin
    assert_equal(1, (1..10).begin)
    assert_equal("a", ("a".."z").begin)
    assert_equal(1, (1...10).begin)
    assert_equal("a", ("a"..."z").begin)
  end

  def test_each
    index = 1
    count = 0
    (1..10).each {|x| assert_equal(index, x)
      index += 1
      count += 1 }
    assert_equal(10,count)

    index = "A"
    count = 0
    ("A".."J").each {|x| assert_equal(index, x)
      index.succ!
      count += 1 }
    assert_equal(10,count)

  end

  def test_end
    assert_equal(10, (1..10).end)
    assert_equal(11, (1...11).end)
    assert_equal("z", ("a".."z").end)
    assert_equal("A", ("a"..."A").end)
  end

  def test_eql?
    generic_test_EQUAL(:eql?)
  end

  def test_exclude_end?
    assert_equal(true, (1...10).exclude_end?)
    assert_equal(false,(1..10).exclude_end?)
    assert_equal(true, ("A"..."Z").exclude_end?)
    assert_equal(false,("A".."Z").exclude_end?)
  end

  def test_first
    assert_equal(1, (1..10).first)
    assert_equal("a", ("a".."z").first)
    assert_equal(1, (1...10).first)
    assert_equal("a", ("a"..."z").first)
  end

  def test_hash
    assert_equal((5..9).hash, (5..9).hash)
    assert_equal((51..111).hash, (51..111).hash)

    assert_equal((5...9).hash, (5...9).hash)
    assert_equal((51...111).hash, (51...111).hash)

    # these comparisons doesn't have to be false, it just seems a good
    # idea that a small "delta" should give a real "delta" in the hash
    #
    assert_not_equal((5..9).hash, (5...9).hash)

    assert_not_equal((5..9).hash, (5..8).hash)
    assert_not_equal((5..9).hash, (5..10).hash)
    assert_not_equal((5..9).hash, (4..9).hash)
    assert_not_equal((5..9).hash, (6..9).hash)
  end

  def test_include?
    is = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    xs = is.map {|x| 0.5 + x}
    iss = ["aj", "ak", "al", "am", "an" ,"ao" "ap"]
    xss = ["ajjj", "akkk", "alll", "ammm", "annn" ,"aooo" "appp"]

    # as discrete range
    assert_equal([4, 5, 6, 7 ],    is.select {|i| (4..7).include?(i) })
    assert_equal([4, 5, 6],        is.select {|i| (4...7).include?(i) })

    assert_equal(["ak","al","am"], iss.select {|i| ("ak".."am").include?(i) })
    assert_equal(["ak","al"],      iss.select {|i| ("ak"..."am").include?(i) })

    # as continuous range
    assert_equal([4.5, 5.5, 6.5],  xs.select {|x| (4..7).include?(x) })
    assert_equal([4.5, 5.5, 6.5],  xs.select {|x| (4...7).include?(x) })

    assert_equal(["akkk","alll"],  xss.select {|i| ("ak".."am").include?(i) })
    assert_equal(["akkk","alll"],  xss.select {|i| ("ak"..."am").include?(i) })
  end

  def test_last
    assert_equal(10, (1..10).last)
    assert_equal(11, (1...11).last)
    assert_equal("z", ("a".."z").last)
    assert_equal("A", ("a"..."A").last)
  end

  Version.less_than("1.7") do
    def test_length
      assert_equal(10, (1..10).length)
      assert_equal(10, (1...11).length)
      assert_equal(1000, (1..1000).length)
      assert_equal(26, ("A".."Z").length)
    end
  end

  def test_member?
    is = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    xs = is.map {|x| 0.5 + x}
    iss = ["aj", "ak", "al", "am", "an" ,"ao" "ap"]
    xss = ["ajjj", "akkk", "alll", "ammm", "annn" ,"aooo" "appp"]

    # as discrete range
    assert_equal([4, 5, 6, 7 ],    is.select {|i| (4..7).member?(i) })
    assert_equal([4, 5, 6],        is.select {|i| (4...7).member?(i) })

    assert_equal(["ak","al","am"], iss.select {|i| ("ak".."am").member?(i) })
    assert_equal(["ak","al"],      iss.select {|i| ("ak"..."am").member?(i) })

    Version.less_or_equal("1.8.1") do
      # does NOT work as continuous range (c.f. include?)
      assert_equal([],  xs.select {|x| (4..7).member?(x) })
      assert_equal([],  xs.select {|x| (4...7).member?(x) })

      assert_equal([],  xss.select {|i| ("ak".."am").member?(i) })
      assert_equal([],  xss.select {|i| ("ak"..."am").member?(i) })
    end
    Version.greater_than("1.8.1") do
      # as continuous range
      assert_equal([4.5, 5.5, 6.5],  xs.select {|x| (4..7).member?(x) })
      assert_equal([4.5, 5.5, 6.5],  xs.select {|x| (4...7).member?(x) })

      assert_equal(["akkk","alll"],  xss.select {|i| ("ak".."am").member?(i) })
      assert_equal(["akkk","alll"],  xss.select {|i| ("ak"..."am").member?(i) })
    end
  end

  Version.less_than("1.7") do
    def test_size
      assert_equal(10, (1..10).size)
      assert_equal(10, (1...11).size)
      assert_equal(1000, (1..1000).size)
      assert_equal(26, ("A".."Z").size)
    end
  end

  def _step_tester(acc_facit, range, *step_args)
    acc = []
    res = range.step(*step_args) {|x| acc << x }
    assert_equal(acc_facit, acc)
    assert_same(range, res)
  end

  def test_step
    # n=1 default in step(n)
    _step_tester([5,6,7,8,9], 5..9)
    _step_tester([5,6,7,8],   5...9)

    # explicit n=1
    _step_tester([5,6,7,8,9], 5..9,   1)
    _step_tester([5,6,7,8],   5...9,  1)

    # n=2
    _step_tester([5,7,9],     5..9,   2)
    _step_tester([5,7],       5...9,  2)

    # n=3
    _step_tester([5,8],       5..9,   3)
    _step_tester([5,8],       5...9,  3)

    # n=4
    _step_tester([5,9],       5..9,   4)
    _step_tester([5],         5...9,  4)
  end

  def test_to_s
    assert_equal("1..10",(1..10).to_s)
  end

end

Rubicon::handleTests(TestRange) if $0 == __FILE__
