$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'

#
# NOTICE: These tests assume that your local time zone is *not* GMT.
#

class T
  attr :orig
  attr :amt
  attr :result
  def initialize(a1, anAmt, a2)
    @orig = a1
    @amt = anAmt
    @result = a2
  end
  def to_s
    @orig.join("-")
  end
end

class TestTime < Rubicon::TestCase

  ONEDAYSEC = 60 * 60 * 24

  #
  # Test month name to month number
  #
  @@months = { 
    'Jan' => 1,
    'Feb' => 2,
    'Mar' => 3,
    'Apr' => 4,
    'May' => 5,
    'Jun' => 6,
    'Jul' => 7,
    'Aug' => 8,
    'Sep' => 9,
    'Oct' => 10,
    'Nov' => 11,
    'Dec' => 12
  }


  #
  # A random selection of interesting dates
  #
  @@dates = [ 
    #                   Source  +   amt         ==   dest
    T.new([1999, 12, 31, 23,59,59], 1,               [2000,  1,  1,  0,0,0]),
    T.new([2036, 12, 31, 23,59,59], 1,               [2037,  1,  1,  0,0,0]),
    T.new([2000,  2, 28, 23,59,59], 1,               [2000,  2, 29, 0,0,0]),
    T.new([1970,  2, 1,   0, 0, 0], ONEDAYSEC,       [1970,  2,  2,  0,0,0]),
    T.new([2000,  7, 1,   0, 0, 0], 32 * ONEDAYSEC,  [2000,  8,  2,  0,0,0]),
    T.new([2000,  1, 1,   0, 0, 0], 366 * ONEDAYSEC, [2001,  1,  1,  0,0,0]),
    T.new([2001,  1, 1,   0, 0, 0], 365 * ONEDAYSEC, [2002,  1,  1,  0,0,0]),

    T.new([2000,  1, 1,   0, 0, 0], 0,               [2000,  1,  1,  0,0,0]),
    T.new([2000,  2, 1,   0, 0, 0], 0,               [2000,  2,  1,  0,0,0]),
    T.new([2000,  3, 1,   0, 0, 0], 0,               [2000,  3,  1,  0,0,0]),
    T.new([2000,  4, 1,   0, 0, 0], 0,               [2000,  4,  1,  0,0,0]),
    T.new([2000,  5, 1,   0, 0, 0], 0,               [2000,  5,  1,  0,0,0]),
    T.new([2000,  6, 1,   0, 0, 0], 0,               [2000,  6,  1,  0,0,0]),
    T.new([2000,  7, 1,   0, 0, 0], 0,               [2000,  7,  1,  0,0,0]),
    T.new([2000,  8, 1,   0, 0, 0], 0,               [2000,  8,  1,  0,0,0]),
    T.new([2000,  9, 1,   0, 0, 0], 0,               [2000,  9,  1,  0,0,0]),
    T.new([2000, 10, 1,   0, 0, 0], 0,               [2000, 10,  1,  0,0,0]),
    T.new([2000, 11, 1,   0, 0, 0], 0,               [2000, 11,  1,  0,0,0]),
    T.new([2000, 12, 1,   0, 0, 0], 0,               [2000, 12,  1,  0,0,0]), 

    T.new([2001,  1, 1,   0, 0, 0], 0,               [2001,  1,  1,  0,0,0]),
    T.new([2001,  2, 1,   0, 0, 0], 0,               [2001,  2,  1,  0,0,0]),
    T.new([2001,  3, 1,   0, 0, 0], 0,               [2001,  3,  1,  0,0,0]),
    T.new([2001,  4, 1,   0, 0, 0], 0,               [2001,  4,  1,  0,0,0]),
    T.new([2001,  5, 1,   0, 0, 0], 0,               [2001,  5,  1,  0,0,0]),
    T.new([2001,  6, 1,   0, 0, 0], 0,               [2001,  6,  1,  0,0,0]),
    T.new([2001,  7, 1,   0, 0, 0], 0,               [2001,  7,  1,  0,0,0]),
    T.new([2001,  8, 1,   0, 0, 0], 0,               [2001,  8,  1,  0,0,0]),
    T.new([2001,  9, 1,   0, 0, 0], 0,               [2001,  9,  1,  0,0,0]),
    T.new([2001, 10, 1,   0, 0, 0], 0,               [2001, 10,  1,  0,0,0]),
    T.new([2001, 11, 1,   0, 0, 0], 0,               [2001, 11,  1,  0,0,0]),
    T.new([2001, 12, 1,   0, 0, 0], 0,               [2001, 12,  1,  0,0,0]),
  ]


  #
  # Check a particular date component -- m is the method (day, month, etc)
  # and i is the index in the date specifications above.
  #
  def checkComponent(m, i)
    @@dates.each do |x|
      msg = "\nTesting method Time."+m.id2name+" with "+x.orig.join(' ')+":\n"
      assert_equal(x.orig[i], Time.local(*x.orig).send(m), msg)
      assert_equal(x.result[i], Time.local(*x.result).send(m), msg)
      assert_equal(x.orig[i], Time.gm(*x.orig).send(m), msg)
      assert_equal(x.result[i], Time.gm(*x.result).send(m), msg)
    end
  end

  #
  # Ensure against time travel
  #
  def test_00sanity
    Time.now.to_i > 960312287 # Tue Jun  6 13:25:06 EDT 2000
  end

  # Method tests:

  def test_CMP # '<=>'
    @@dates.each do |x|
      if (x.amt != 0)
        assert_equal(1, Time.local(*x.result) <=> Time.local(*x.orig),
                     "#{x.result} should be > #{x.orig}")

        assert_equal(-1, Time.local(*x.orig) <=> Time.local(*x.result))
        assert_equal(0, Time.local(*x.orig) <=> Time.local(*x.orig))
        assert_equal(0, Time.local(*x.result) <=> Time.local(*x.result))
        
        assert_equal(1,Time.gm(*x.result) <=> Time.gm(*x.orig))
        assert_equal(-1,Time.gm(*x.orig) <=> Time.gm(*x.result))
        assert_equal(0,Time.gm(*x.orig) <=> Time.gm(*x.orig))
        assert_equal(0,Time.gm(*x.result) <=> Time.gm(*x.result))
      end
    end
  end

  def test_MINUS # '-'
    @@dates.each do |x|
      # Check subtracting an amount in seconds
      assert_equal(Time.local(*x.result) - x.amt, Time.local(*x.orig))
      assert_equal(Time.gm(*x.result) - x.amt, Time.gm(*x.orig))
      # Check subtracting two times
      assert_equal(Time.local(*x.result) - Time.local(*x.orig), x.amt)
      assert_equal(Time.gm(*x.result) - Time.gm(*x.orig), x.amt)
    end
  end

  def test_PLUS # '+'
    @@dates.each do |x|
      assert_equal(Time.local(*x.orig) + x.amt, Time.local(*x.result))
      assert_equal(Time.gm(*x.orig) + x.amt, Time.gm(*x.result))
    end
  end

  def test__dump
  end

  def os_specific_epoch
    if $os == MsWin32 || $os == JRuby
      "Thu Jan 01 00:00:00 1970"
    else
      "Thu Jan  1 00:00:00 1970"
    end
  end

  def test_asctime
    expected = os_specific_epoch
    assert_equal(expected, Time.at(0).gmtime.asctime)
  end

  def test_clone
    for taint in [ false, true ]
      for frozen in [ false, true ]
        a = Time.now
        a.taint  if taint
        a.freeze if frozen
        b = a.clone

        assert_equal(a, b)
        assert(a.__id__ != b.__id__)
        assert_equal(a.frozen?, b.frozen?)
        assert_equal(a.tainted?, b.tainted?)
      end
    end
  end

  def test_ctime
    expected = os_specific_epoch
    assert_equal(expected, Time.at(0).gmtime.ctime)
  end

  def test_day
    checkComponent(:day, 2)
  end

  def test_eql?
    t1=Time.now
    t2=t1 
    t2+= 2e-6
    sleep(0.1)
    assert(!t1.eql?(Time.now))
    assert(!t1.eql?(t2))
  end

  def test_gmt?
    assert(!Time.now.gmt?)
    assert(Time.now.gmtime.gmt?)
    assert(!Time.local(2000).gmt?)
    assert(Time.gm(2000).gmt?)
  end

  def test_gmtime
    t = Time.now
    loc = Time.at(t)
    assert(!t.gmt?)
    t.gmtime
    assert(t.gmt?)
    assert(t.asctime != loc.asctime)
  end

  def test_hash
    t = Time.now
    t2 = Time.at(t)
    sleep(0.1)
    t3 = Time.now
    assert(t.hash == t2.hash)
    assert(t.hash != t3.hash)
  end

  def test_hour
    checkComponent(:hour, 3)
  end

  def test_isdst
    # This code is problematic: how do I find out the exact
    # date and time of the dst switch for all the possible
    # timezones in which this code runs? For now, I'll just check
    # midvalues, and add boundary checks for the US. I know this won't 
    # work in some parts of the US, even, so I'm looking for
    # better ideas

    zone = Time.now.zone

    # Are we in the US?

    if ["EST", "EDT",
        "CST", "CDT",
        "MST", "MDT",
        "PST", "PDT"].include? zone

      dtest = [ 
        [false,     2000, 1, 1],
        [true,  2000, 7, 1],
      ]

      dtest.push(
                 [true,  2000, 4, 2, 4],
                 [false, 2000, 10, 29, 4],
                 [false, 2000, 4,2,1,59],   # Spring forward
                 [true,  2000, 4,2,3,0],
                 [true,  2000, 10,29,1,59], # Fall back
                 [false, 2000, 10,29,2,0]
                 )

      dtest.each do |x|
        result = x.shift
        assert_equal(result, Time.local(*x).isdst,
                     "\nExpected #{x.join(',')} to be dst=#{result}")
      end
    else
      skipping("Don't know how to do timezones");
    end
  end

  def test_localtime
    t = Time.now.gmtime
    utc = Time.at(t)
    assert(t.gmt?)
    t.localtime
    assert(!t.gmt?)
    assert(t.asctime != utc.asctime)
  end

  def test_mday
    checkComponent(:mday, 2)
  end

  def test_min
    checkComponent(:min, 4)
  end

  def test_mon
    checkComponent(:mon, 1)
  end

  def test_month
    checkComponent(:month, 1)
  end

  def test_sec
    checkComponent(:sec, 5)
  end

  def test_strftime
    # Sat Jan  1 14:58:42 2000
    t = Time.local(2000,1,1,14,58,42)

    stest = {
       '%a' => 'Sat',
       '%A' => 'Saturday',
       '%b' => 'Jan',
       '%B' => 'January',
       #'%c',  The preferred local date and time representation,
       '%d' => '01',
       '%H' => '14',
       '%I' => '02',
       '%j' => '001',
       '%m' => '01',
       '%M' => '58',
       '%p' => 'PM',
       '%S' => '42',
       '%U' => '00',
       '%W' => '00',
       '%w' => '6',
       #'%x',  Preferred representation for the date alone, no time\\
       #'%X',  Preferred representation for the time alone, no date\\
       '%y' =>  '00',
       '%Y' =>  '2000',
       #'%Z',  Time zone name\\
       '%%' =>  '%',
      }

    stest.each {|flag,val|
      assert_equal("Got "+val,t.strftime("Got " + flag))
    }

  end

  def test_to_a
    t = Time.now
    a = t.to_a
    assert_equal(t.sec,  a[0])
    assert_equal(t.min,  a[1])
    assert_equal(t.hour, a[2])
    assert_equal(t.day,  a[3])
    assert_equal(t.month,a[4])
    assert_equal(t.year, a[5])
    assert_equal(t.wday, a[6])
    assert_equal(t.yday, a[7])
    assert_equal(t.isdst,a[8])
    assert_equal(t.zone, a[9])
  end

  def test_to_f
    t = Time.at(10000,1066)
    assert_equal(10000.001066, t.to_f)
  end

  def test_to_i
    t = Time.at(0)
    assert_equal(0, t.to_i)
    t = Time.at(10000)
    assert_equal(10000, t.to_i)
  end

  def test_to_s
    t = Time.now
    assert_equal(t.strftime("%a %b %d %H:%M:%S %Z %Y"),t.to_s)
  end

  def test_tv_sec
    t = Time.at(0)
    assert_equal(0,t.tv_sec)
    t = Time.at(10000)
    assert_equal(10000,t.tv_sec)
  end

  def test_tv_usec
    t = Time.at(10000,1066)
    assert_equal(1066,t.tv_usec)
  end

  def test_usec
    t = Time.at(10000,1066)
    assert_equal(1066,t.usec)
  end

  def test_wday
    t = Time.local(2001, 4, 1)

    6.times {|i|
      assert_equal(i,t.wday)
      t += ONEDAYSEC
    }
  end

  def test_yday
    t = Time.local(2001, 1, 1)
    365.times {|i|
      assert_equal(i+1,t.yday)
      t += ONEDAYSEC
    }
    
  end

  def test_year
    checkComponent(:year, 0)
  end

  def test_zone
    gmt = "UTC"
    Version.less_than("1.7") do gmt = "GMT" end
    t = Time.now.gmtime
    assert_equal(gmt, t.zone)
    t = Time.now
    assert(gmt != t.zone)
  end

  def test_s__load
  end

  def test_s_at
    t = Time.now
    sec = t.to_i
    assert_equal(0, Time.at(0).to_i)
    assert_equal(t, Time.at(t))
    assert((Time.at(sec,1000000).to_f - Time.at(sec).to_f) == 1.0)
  end

  def test_s_gm
    assert_raises(ArgumentError) { Time.gm }
    assert(Time.gm(2000) != Time.local(2000))
    assert_equal(Time.gm(2000), Time.gm(2000,1,1,0,0,0))
    assert_equal(Time.gm(2000,nil,nil,nil,nil,nil), Time.gm(2000,1,1,0,0,0))
    assert_raises(ArgumentError) { Time.gm(2000,0) }
    assert_raises(ArgumentError) { Time.gm(2000,13) }
    assert_raises(ArgumentError) { Time.gm(2000,1,1,24) }
    Time.gm(2000,1,1,23)
    @@months.each do |month, num| 
      assert_equal(Time.gm(2000,month), Time.gm(2000,num,1,0,0,0))
      assert_equal(Time.gm(1970,month), Time.gm(1970,num,1,0,0,0))
      assert_equal(Time.gm(2037,month), Time.gm(2037,num,1,0,0,0))
    end
    t = Time.gm(2000,1,1)
    a = t.to_a
    assert_equal(Time.gm(*a),t)
  end

  def test_s_local
    assert_raises(ArgumentError) { Time.local }
    assert(Time.gm(2000) != Time.local(2000))
    assert_equal(Time.local(2000), Time.local(2000,1,1,0,0,0))
    assert_equal(Time.local(2000,nil,nil,nil,nil,nil), Time.local(2000,1,1,0,0,0))
    assert_raises(ArgumentError) { Time.local(2000,0) }
    assert_raises(ArgumentError) { Time.local(2000,13) }
    assert_raises(ArgumentError) { Time.local(2000,1,1,24) }
    Time.local(2000,1,1,23)
    @@months.each do |month, num| 
      assert_equal(Time.local(2000,month), Time.local(2000,num,1,0,0,0))
      assert_equal(Time.local(1971,month), Time.local(1971,num,1,0,0,0))
      assert_equal(Time.local(2037,month), Time.local(2037,num,1,0,0,0))
    end
    t = Time.local(2000,1,1)
    a = t.to_a
    assert_equal(Time.local(*a),t)
  end

  def test_s_mktime
    #
    # Test insufficient arguments
    #
    assert_raises(ArgumentError) { Time.mktime }
    assert(Time.gm(2000) != Time.mktime(2000))
    assert_equal(Time.mktime(2000), Time.mktime(2000,1,1,0,0,0))
    assert_equal(Time.mktime(2000,nil,nil,nil,nil,nil), Time.mktime(2000,1,1,0,0,0))
    assert_raises(ArgumentError) { Time.mktime(2000,0) }
    assert_raises(ArgumentError) { Time.mktime(2000,13) }
    assert_raises(ArgumentError) { Time.mktime(2000,1,1,24) }
    Time.mktime(2000,1,1,23)

    #
    # Make sure spelled-out month names work
    #
    @@months.each do |month, num| 
      assert_equal(Time.mktime(2000,month), Time.mktime(2000,num,1,0,0,0))
      assert_equal(Time.mktime(1971,month), Time.mktime(1971,num,1,0,0,0))
      assert_equal(Time.mktime(2037,month), Time.mktime(2037,num,1,0,0,0))
    end
    t = Time.mktime(2000,1,1)
    a = t.to_a
    assert_equal(Time.mktime(*a),t)
  end

  def test_s_new
    t1 = Time.new
    sleep 1
    t2 = Time.new
    d = t2.to_f - t1.to_f
    assert(d > 0.9 && d < 1.1)
  end

  def test_s_now
    t1 = Time.now
    sleep 1
    t2 = Time.now
    d = t2.to_f - t1.to_f
    assert(d > 0.9 && d < 1.1)
  end

  def test_s_times
    Version.less_than("1.7") do
      assert_instance_of(Struct::Tms, Time.times)
    end
    Version.greater_or_equal("1.7") do
      assert_instance_of(Struct::Tms, Process.times)
    end
  end

end

Rubicon::handleTests(TestTime) if $0 == __FILE__

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    