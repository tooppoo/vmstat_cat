#encoding: utf-8

require_relative '../core/config'

require 'test/unit'
require 'analyzer'
require 'io/vmstat_reader'

include VmstatCat
include VmstatCat::IO

class TestAnalyzer < Test::Unit::TestCase
  def setup
    sample_log_path = File.expand_path(__dir__ + '/io/test.log')
    reader = VmstatReader.new(sample_log_path)
    @read_data = reader.read_single
  end
  
  def test_analyze_header
    expected = {:page_size => 4096}
    actual = Analyzer::execute(@read_data.header, Analyzer::Part::Header)
    
    assert_equal(expected, actual)
  end
  
  def test_analyze_body
    expected = {
      :free => 19754,
      :active => 701005,
      :inactive => 1103397,
      :speculative => 6770,
      :wired_down => 265668,
      :translation_faults => 108470704,
      :copy_on_write => 12199065,
      :zero_filled => 54393992,
      :reactivated => 55794,
      :pageins => 3953684,
      :pageouts => 2303
    }
    actual = Analyzer::execute(@read_data.body, Analyzer::Part::Body)
    
    assert_equal(expected, actual)
  end
  
  def test_analyze_footer
    expected = {
      :cache => 579187,
      :hits => 15,
      :hit_rate => 0
    }
    actual = Analyzer::execute(@read_data.footer, Analyzer::Part::Footer)
  end
  
  def test_analyze
    expected = {
      :page_size => 4096,
      :free => 19754,
      :active => 701005,
      :inactive => 1103397,
      :speculative => 6770,
      :wired_down => 265668,
      :translation_faults => 108470704,
      :copy_on_write => 12199065,
      :zero_filled => 54393992,
      :reactivated => 55794,
      :pageins => 3953684,
      :pageouts => 2303,
      :cache => 579187,
      :hits => 15,
      :hit_rate => 0
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