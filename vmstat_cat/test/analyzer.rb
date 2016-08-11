#encoding: utf-8

require_relative File::expand_path('../core/config', __dir__)

require 'test/unit'
require 'analyzer'
require 'io/vmstat_reader'

include VmstatCat
include VmstatCat::IO

class TestAnalyzer < Test::Unit::TestCase
  def setup
    sample_log_path = File.expand_path(__dir__ + '/io/sample.log')
    reader = VmstatReader.new(sample_log_path)
    @read_data = reader.read_single
  end

  def test_analyze_header
    expected = {:page_size => 4096}
    actual = Analyzer::execute(@read_data, Analyzer::Part::Header)

    assert_equal(expected, actual)
  end

  def test_analyze_body
    expected = {

      :"Pages free"                     =>        "538494",
      :"Pages active"                   =>        "857164",
      :"Pages inactive"                 =>         "96087",
      :"Pages speculative"             =>         "73793",
      :"Pages throttled"                =>             "0",
      :"Pages wired down"               =>        "252371",
      :"Pages purgeable"                =>        "207561",
      :"Translation faults"             =>      "41234592",
      :"Pages copy-on-write"            =>        "944859",
      :"Pages zero filled"              =>      "25838868",
      :"Pages reactivated"              =>        "420552",
      :"Pages purged"                   =>        "282765",
      :"File-backed pages"              =>        "208787",
      :"Anonymous pages"                =>        "818257",
      :"Pages stored in compressor"     =>        "587616",
      :"Pages occupied by compressor"   =>        "278734",
      :Decompressions                 =>       "1107375",
      :Compressions                   =>       "1904226",
      :Pageins                        =>       "2532187",
      :Pageouts                       =>          "1587",
      :Swapins                        =>       "1062813",
      :Swapouts                       =>       "1093920"
    }
    actual = Analyzer::execute(@read_data, Analyzer::Part::Body)

    assert_equal(expected, actual)
  end

  def test_analyze_footer
    expected = {
      :cache => 579187,
      :hits => 15,
      :hit_rate => 0
    }
    actual = Analyzer::execute(@read_data, Analyzer::Part::Footer)
  end

  def test_analyze
    expected = {
      :page_size    => 4096,
      :"Pages free"                     =>        "538494",
      :"Pages active"                   =>        "857164",
      :"Pages inactive"                 =>         "96087",
      :"Pages speculative"             =>         "73793",
      :"Pages throttled"                =>             "0",
      :"Pages wired down"               =>        "252371",
      :"Pages purgeable"                =>        "207561",
      :"Translation faults"             =>      "41234592",
      :"Pages copy-on-write"            =>        "944859",
      :"Pages zero filled"              =>      "25838868",
      :"Pages reactivated"              =>        "420552",
      :"Pages purged"                   =>        "282765",
      :"File-backed pages"              =>        "208787",
      :"Anonymous pages"                =>        "818257",
      :"Pages stored in compressor"     =>        "587616",
      :"Pages occupied by compressor"   =>        "278734",
      :Decompressions                 =>       "1107375",
      :Compressions                   =>       "1904226",
      :Pageins                        =>       "2532187",
      :Pageouts                       =>          "1587",
      :Swapins                        =>       "1062813",
      :Swapouts                       =>       "1093920"
    }
    actual = Analyzer::execute(@read_data)

    assert_equal(expected, actual)
  end

  def test_analyze_empty
    test = lambda{|arg|
      expected = {}
      actual = Analyzer::execute(arg)

      assert_equal(expected, actual)
    }
    test.call(nil)
    test.call({})
  end
end
