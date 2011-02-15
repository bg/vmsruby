$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


# The regexp class outputs warnings to $stderr
# We don't want users of rubicon to see these

# Huh?  We're >= 1.8 but have no stringio.rb. Disabling this clause
# and enabling the next.
#Version.greater_or_equal("1.8") do
#	require 'stringio'
#	def IO.capture_stderr(&block)
#		e = StringIO.new
#		$stderr = e
#		block.call
#		return e.string
#	ensure
#		$stderr = STDERR
#	end 
#end

#Version.less_than("1.8") do
	def IO.capture_stderr(&block)
		block.call
		"not implemented"
	end
#end


class TestRegularExpressions < Rubicon::TestCase


  def testBasics
    assert("abc" !~ /^$/)
    assert("abc\n" !~ /^$/)
    assert("abc" !~ /^d*$/)
    assert(("abc" =~ /d*$/) == 3)
    assert_equal(0, "" =~ /^$/)
    assert_equal(0, "\n" =~ /^$/)
    assert_equal(2, "a\n\n" =~ /^$/)
    assert("abcabc" =~ /.*a/ && $& == "abca")
    assert("abcabc" =~ /.*c/ && $& == "abcabc")
    assert("abcabc" =~ /.*?a/ && $& == "a")
    assert("abcabc" =~ /.*?c/ && $& == "abc")
    assert(/(.|\n)*?\n(b|\n)/ =~ "a\nb\n\n" && $& == "a\nb")
    
    assert(/^(ab+)+b/ =~ "ababb" && $& == "ababb")
    assert(/^(?:ab+)+b/ =~ "ababb" && $& == "ababb")
    assert(/^(ab+)+/ =~ "ababb" && $& == "ababb")
    assert(/^(?:ab+)+/ =~ "ababb" && $& == "ababb")
    
    assert(/(\s+\d+){2}/ =~ " 1 2" && $& == " 1 2")
    assert(/(?:\s+\d+){2}/ =~ " 1 2" && $& == " 1 2")

    x = "ABCD\nABCD\n"
    x.gsub!(/((.|\n)*?)B((.|\n)*?)D/) {$1+$3}
    assert_equal("AC\nAC\n", x)

    assert_equal(0, "foobar" =~ /foo(?=(bar)|(baz))/)
    assert_equal(0, "foobaz" =~ /foo(?=(bar)|(baz))/)
  end

  def testReferences
    x = "a.gif"
    assert_equal("gif",     x.sub(/.*\.([^\.]+)/, '\1'))
    assert_equal("b.gif",   x.sub(/.*\.([^\.]+)/, 'b.\1'))
    assert_equal("",        x.sub(/.*\.([^\.]+)/, '\2'))
    assert_equal("ab",      x.sub(/.*\.([^\.]+)/, 'a\2b'))
    assert_equal("<a.gif>", x.sub(/.*\.([^\.]+)/, '<\&>'))
  end

  def testGlobal
    file_name = nil
    start = File.dirname($0)
    for base in [".", "language"]
      file_name = File.join(start, base, 'regexp.test')
      break if File.exist? file_name
      file_name = nil
    end

    fail("Could not find file containing regular expression tests") unless file_name

    lineno =  0
    IO.foreach(file_name) do |line|
      lineno += 1
      line.sub!(/\r?\n\z/, '')
      next if /^#/ =~ line || /^$/ =~ line
      pat, subject, result, repl, expect = line.split(/\t/, 6)
      begin
	for mes in [subject, expect]
	  if mes
	    mes.gsub!(/\\n/, "\n")
	    mes.gsub!(/\\000/, "\0")
	    mes.gsub!(/\\255/, "\255") #"
	  end
	end

	regexp = nil
	ignore = IO.capture_stderr do
		regexp = Regexp.new(pat, false)
	end
	reg = regexp.match subject
        
	case result
	when 'y'
          assert_not_nil(reg, "Expected a match: #{lineno}: '#{line}'")
          if repl != '-'
            eu = eval('"' + repl + '"')
            assert(expect == eu, "Expected '#{expect.inspect}, " +
		   "got '#{eu.inspect}'\n" +
		   "#{lineno}: '#{line.inspect}'")
          end
	when 'n'
	  assert(!reg, "Did not expect a match: #{lineno} '#{line}'")
	when 'c'
          assert_fail("'#{line}' should not have compiled")
	end
      rescue RegexpError
        assert_equal('c', result, 
                     "Regular expression did not compile: #{lineno} '#{line}'")
	fail_msg = $!.to_s
        assert_equal(expect, fail_msg, "Expected error: '#{expect}'")
#      rescue
#	assert_fail("#$!: #{lineno}: '#{line}'")
      end
    end
  end

end

# Run these tests if invoked directly

Rubicon::handleTests(TestRegularExpressions) if $0 == __FILE__
                                                                                                                                                                                                                                                                                                                                                                                                                                                              CIRCUMCISION    ) CITY             CLASS           CLASSICAL       CNN              CNN             { CODES           �CODING          uCODING          �COLOR           �COLOURFUL       |COLUMBIA         COMBINATION     � COME            ' COME            P COMING          KCOMME            COMMENT         P COMMERCIALS     COMMON          COMMONLY        + COMMUNITY       KCOMMUNITY       ) COMMUNITY       P COMPARISONS     b COMPONENTS      O COMPUTER        cCOMPUTER        u        COMPUTER        �COMPUTER        O COMPUTERS       cCOMPUTERS       O COMPUTERS       � COMPUTERS       � COMPUTERS       ,COMPUTERS        COMPUTERS       �COMPUTERS       � COMPUTERS       COMPUTERS       � CONCEPT         �CONCEPTS        �CONCERTED       } CONCERTED       |CONCLUDES       |CONDITIONS      |CONFIRMATION    ) CONSCIOUS       bCONSIDERATE     8CONSISTS        CONSUMER        CONSUMER        } CONSUMERS       CONSUMERS       } CONSUMPTION     CONTAMINATION             CONTEMPORARY    b CONTRA          { CONTRADICTIONS  ) CONTRAST        |CONTRASTED      KCONTROLLING     4 COOK            6COPIES          COPIES          + CORRECTLY       COSMIC          bCOVERS          <CRAFT           6CREATE          } CREATES         } CREATION        CREDIT          CRITERIA        } CRITIC          |CRITICIZES      } CRITTER         " CRITTER         xCRUSADER        } CULTURE         ) CUMULATIVELY    + CUSTOMS         + D1              �D1              ?         D2              K D2              cD2              uD2              �D2              O D2              b D2              ) D2              bD2              6 D2              8D2               D2              <D4              K D4              D4              D4              } D4               D4              b D4              KD4               D4              + D4              ? D4              6D4              d D4              c D4              rD4              P D4              |        D9                D9              D9               D9               D9              � D9              � D9              � D9              ,D9               D9              �D9              � D9              D9              � D9              D9              { D9              " D9              xD9              +D9              'D9              / D9              S D9              s D9              M D9              � D9              z D9              y D9              � D9              _         DAMAGED          DARLINGTON      { DASH             DAY             <DAY             M DAYS            KDDDDD           DE               DEAL            p DEALING         c DEALS           cDEALT           + DECIDES         c DECIMAL         �DECK            wDECORATING      u DEFINES         �DEGREE           DELIBERATE       DELIBERATELY    � DEPRESSED       b DEPRESSIONS     b DES              DESCRIPTIONS    DESCRIPTIONS    + DESIGN          $ DESIGNING       # DESKTOP         �         DESPERATE       |DETAILED        S DEVELOPING      O DEVELOPS        �DEVELOPS        O DEVELOPS        |DEVOTED         DIALOGUE        } DIALOGUE        + DIFFERENCES     b DIFFICULTY      + DIGITAL         cDIGITAL         uDIGITAL         �DIGITAL         O DISCOURAGE      |DISCOVER        DISCOVER         DISCUSS         DISCUSSES         DISCUSSES       <DISCUSSING      � DISCUSSION      DISCUSSION      } DISORDER        b DISORDERS       b DISPLAY          DISTINCTION     b         DISTORTION      DISTRIBUTED     DIVERGENT       } DIVISION        KDIVISION         DO              KDOCTOR           DOCUMENTS       _ DOG             | DOG              DONT            " DONT            ? DONT            , DONT            g DONT             DONT            F DONT            �DR               DR              bDRAMATIC        _ DRAWN           b DRAWS           DREAMS          |DRESSED         8DYMAXION         DYSTHYMIC       b EACH            KEADING                   EARLIER         |EARTH           J EATER           6EDDIE           ( EDIBLE          EEEEE           EFFECT          8EFFECTS         8ELECTRICITY     P ELECTRONICS     O ELEMENT         O ELLEN           { EMBEDDED        ,EMOTIONAL       } EMPHASIZE       b EMPHASIZES      KEMPHASIZES      8EMPHASIZES      <ENCOURAGE       } ENCOURAGES      8ENGLISH         |ENGLISH SPEAKIN + ENJOY           |ENSURE          ENVIABLE        |EQUIPMENT       8EQUIPT           ERASING                  ERNEST          bET               ETHICS          EVENTS          ) EVERY           M EVERYDAY        + EVERYONE        KEVERYONE        P EVERYONE        |EXAGGERATED      EXAMINE         |EXAMINES        ) EXAMINES        � EXAMPLE         uEXAMPLE         b EXCEEDS         � EXECUTIVE       } EXHAUST         S EXHIBITING      b EXPERIENCE      ) EXPERIENCES     y EXPERIENCES     � EXPERIMENTS     P EXPERT          6EXPLAINS        ) EXPLANATION     'EXPLORES        S EXPORTED        s         EXPRESSED       EXTE             EXTERNAL        +EYE TO EYE      " F12             vF14             w F15             #F16             x F18             q FACES           y FACT            |FACTOR          } FACTS           FACTUAL         FALL             FALLS           �FAMILAR         } FANTASY         FANTASY         8FARM            KFASHIONABLE     d FEET             FEZ             ) FFFFF           FIELDS          � FIGTER          ; FIGURES         FILES           (         FILM            KFILM            8FILMS           FILMS           FIND            |FINER           d FIRST           FIRST           b FIRST            FIRST           ] FIRST           + FIRSTS          FISHING         % FLICK           KFLICK           P FLOW            uFLUENT          + FOLLOWING       ? FOOTAGE         { FORBIDDEN       ) FORESTS           FORTH           ) FORTY EIGHT     FRENCH          uFRENCH          + FRENCH          c FRIENDLY        bFRIENDS         9         FUNCTIONS       S FUNNY           s FUTURE          |GAP             |GARAGIOLA       K GARDEN          # GARDENS         9 GAS             P GEOGRAPHICAL    _ GEORGE           GET             P GETS            + GETS             GGGGG           GIVES           GIVES           uGIVES           <GLAMOROUS       |GO              ? GO              c GOD             <GOES            % GOING           + GOLD            _ GOOD            ' GOT             6GOVERNMENT       GOWNS           8        GRADE           |GRADES          + GRADUALLY       + GRAMMAR         + GREAT           K GREAT           GREAT           A GREAT           a GREATER         GREATEST        W GREEK           <GROUP           b GROUP           GROWS           KGUIDE           GUIDE           GUIDE           ) GUIDED           GUIDED           GUIDED          �GUIDED          � GUIDED          � GUIDED           GUIDED           GUIDED           GUIDED           GUIDED          �GUIDED          �         GUIDED           GUIDED          GUIDES          + GULLIBILITY     + HANDLE          KHANDLE          P HAPPEN          � HASNT           6HAVENT          � HEAD            - HEAD            � HEADER          DHELPS           KHELPS           P HENRY           � HENRYS          � HERE             HERE            s HERE            P HHHHH           HIFI            - HIFI            � HIGHLIGHTS      K HIGHLIGHTS       HIM             + HIM             c HIMSELF         <HISTORICAL      <        HISTORY         ) HOCKING         bHOLDLIST        qHOLDLIST        )HOLDLIST        HOMES           P HONEST          } HOPES           |HORSE           < HOSTILE         bHTML            P HUMAN           ) HUMAN           bHUMAN           +HUMAN           'HUMAN           / HUMAN           |HUMOROUS        z IDEA            |IDEAS           IDEAS           v IDEAS           M IGNORED         P IIIII           ILLUSTRATE      b IMAGE           P IMAGE           |IMAGES          P         IMAGES          |IMG             P IMPORTANT        IMPROVE         |INCHES           INCLUDE         S INCLUDED        uINCLUDES        K INCLUDES        INCLUDING       <INCREASING      + INCREDIBLE      INDICATE        |INDICATES       uINDICATES       �INDUSTRY        INFLUENCE       8INFORMATION     INNOCENCE       + INNOVATIONS     INSIDE          � INSIDE          � INSIDE          ,INSIDE           INSIDE          �INSIDE          � INSIDE          INSIDE          �         INSIDE          INSTEAD         } INTAKE          S INTENTIONALLY   P INTERDEPENDENCE KINTERESTED      d INTERESTS       } INTERFERE       8INTERIOR        u INTERIOR        $ INTERLUDES      } INTERNAL        +INTERVIEWS      } INTERVIEWS      bINTRODUCES      � INTRODUCTION    �INVENTED        INVGRP           INVOLVED        S INVOLVING       + IRAN            { ISLAM           ) ISOLANT          ISOLATION       K ISSU             JJJJJ           JOE             K JOHN            |        JUST            ) JUST            � JUST            " JUST            P KAT             r KEYWORDS        +KEYWORDS        'KEYWORDS        / KILOBYTES       KIND            |KIT             KIT             r KIT             1 KIT             DKITCHEN         t KITTEN          � KKKKK           KORAN           ) LA               LABOUR          KLABRADOR        �LAKES             LAPTOP           LAWN            a LE              " LE               LEARN           c LEFT            ?         LEFT            P LEGISLATION     LENGTH          LENGTH          � LENGTHY         LENS            8LEVELS          b LF              + LIEU             LIFE            ) LIFE            bLIFE             LIFE            � LIFE            _ LIFESTYLE       |LIGHT           ? LIGHTENED       } LIKE            s LIKE            |LINE            P LINES           LINES           � LISTED           LISTED          rLISTINGS        + LITT            " LITTER          � LITTLE          "         LITTLE          xLITTLE           LIVES           � LLLLL           LOGIC           cLOGIC           �LOGIC           O LOGIC BINARY    uLOISEAU          LONG            8LONG             LOOK            � LOOK            � LOOK            ,LOOK             LOOK            �LOOK            � LOOK            LOOK            � LOOK            LOOK            S LOOK            ? LOOKING         ) LOVE            W LOWER           / LUNGS           'LUNGS           / LUNGS           S         M4T             + MADE            MADE            |MAGAZINE        |MAIN            S MAINFRAME       �MAJOR           b MAKE            MAKE            s MAKEUP          S MAKING          MAMMIFE          MAMMIFERES       MAN             bMANIPULATION     MANITOBA        � MANS            bMANS            <MANUFACTURES    |MARRIAGE        ) MASSIVELY       � MASTERPIECES    MATERIAL        |MATERIALISTIC   ) MATHEMATICS     ( MAY              MAY             rMDNTBLUE GIF    P         ME              " MEDIANET        s MEMBERSHIP      C MEMBERSHIP      ~ MEMORABLE       y MEN             MIG             ; MIGHT           |MINIMUM         + MINOR           b MINUS            MMMMM           MODEL           'MODERN          KMODERN          ) MODERN          |MODIFIED        �MOHAMMED        ) MONEY           MONITOR         �MONTHLY         C MORE            MORE            P MORNING         � MORROCO         ) MOST            MOST            + MOST            |        MOUNTAINS       c MULTINATIONAL    MULTIPLICATION   MY              " MY              ] N W T           � NADER           } NAISSANCE        NAIVE           + NAME            ) NAMED           < NARRATED        K NATURE          + NATURE          y NEED            S NEED            <NEEDS           } NEUTRAL         bNEVER           xNEW             K NEW              NEWBORN         + NEWFOUNDLAND     NEWS            { NEXT            NIAGRA          �NICE             NINETEEN        K         