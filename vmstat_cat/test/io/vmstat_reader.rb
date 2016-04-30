#encoding: utf-8

require_relative '../../core/config'

require 'test/unit'
require 'io/vmstat_reader'

include VmstatCat::IO

class TestVmstatLogReader < Test::Unit::TestCase
  def setup
    sample_log_path = File.expand_path(__dir__ + '/test.log')
    @reader = VmstatReader.new(sample_log_path)
  end
  
  def test_read_single
    record = @reader.read_single
    
    assert_not_equal(nil, record)
    assert_not_equal(nil, record.header)
    assert_not_equal(nil, record.footer)
    assert_not_equal(nil, record.body)
    
    11.times{|i|
      assert_not_equal(nil, record.body[i])
    }
  end
  
  def test_read_header
    expected = 'Mach Virtual Memory Statistics: (page size of 4096 bytes)'
    actual = @reader.read_single.header
    
    assert_equal(expected, actual)
  end
  
  def test_read_footer
    expected = 'Object cache: 15 hits of 579187 lookups (0% hit rate)'
    actual = @reader.read_single.footer
    
    assert_equal(expected, actual)
  end
  
  def test_read_body
    body = @reader.read_single.body
    
    assert_equal('Pages free:                          19754.', body[0])
    assert_equal('Pages active:                       701005.', body[1])
    assert_equal('Pages inactive:                    1103397.', body[2])
    assert_equal('Pages speculative:                    6770.', body[3])
    assert_equal('Pages wired down:                   265668.', body[4])
    assert_equal('"Translation faults":            108470704.', body[5])
    assert_equal('Pages copy-on-write:              12199065.', body[6])
    assert_equal('Pages zero filled:                54393992.', body[7])
    assert_equal('Pages reactivated:                   55794.', body[8])
    assert_equal('Pageins:                           3953684.', body[9])
    assert_equal('Pageouts:                             2303.', body[10])
  end
  
  def test_has_next?
    test = lambda{|expected|
      actual = @reader.has_next?
      
      assert_equal(expected, actual)
    }
    test.call(true)
    @reader.read_single
    test.call(true)
    @reader.read_single
    test.call(true)
    @reader.read_single
    test.call(false)
  end
end
