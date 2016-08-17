#encoding: utf-8

require_relative File::expand_path('../../core/config', __dir__)

require 'test/unit'
require 'io/vmstat_reader'

include VmstatCat::IO

class TestVmstatLogReader < Test::Unit::TestCase
  RECORD_COUNT = 6

  def setup
    sample_log_path = File.expand_path('./sample.log', __dir__)
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
    if VmstatCat::Config::FOOTER_EXISTS then
      expected = 'Object cache: 15 hits of 579187 lookups (0% hit rate)'
      actual = @reader.read_single.footer

      assert_equal(expected, actual)
    end
  end

  def test_read_body
    body = @reader.read_single.body

    assert_equal('Pages free:                              538494.', body[0])
    assert_equal('Pages active:                            857164.', body[1])
    assert_equal('Pages inactive:                           96087.', body[2])
    assert_equal('Pages speculative:                        73793.', body[3])
    assert_equal('Pages throttled:                              0.', body[4])
    assert_equal('Pages wired down:                        252371.', body[5])
    assert_equal('Pages purgeable:                         207561.', body[6])
    assert_equal('"Translation faults":                  41234592.', body[7])
    assert_equal('Pages copy-on-write:                     944859.', body[8])
    assert_equal('Pages zero filled:                     25838868.', body[9])
    assert_equal('Pages reactivated:                       420552.', body[10])
    assert_equal('Pages purged:                            282765.', body[11])
    assert_equal('File-backed pages:                       208787.', body[12])
    assert_equal('Anonymous pages:                         818257.', body[13])
    assert_equal('Pages stored in compressor:              587616.', body[14])
    assert_equal('Pages occupied by compressor:            278734.', body[15])
    assert_equal('Decompressions:                         1107375.', body[16])
    assert_equal('Compressions:                           1904226.', body[17])
    assert_equal('Pageins:                                2532187.', body[18])
    assert_equal('Pageouts:                                  1587.', body[19])
    assert_equal('Swapins:                                1062813.', body[20])
    assert_equal('Swapouts:                               1093920.', body[21])
  end

  def test_body_length
    expected = 22
    actual = @reader.read_single.body.length

    assert_equal(expected, actual)
  end

  def test_has_next?
    test = lambda{|expected|
      actual = @reader.has_next?

      assert_equal(expected, actual)

      @reader.read_single
    }

    (RECORD_COUNT + 1).times{|i|
      test.call(i + 1 < RECORD_COUNT)
    }
  end

  def test_each
    expected_page_size = 4096

    @reader.each{|reader|
      expected = "Mach Virtual Memory Statistics: (page size of #{expected_page_size} bytes)"
      actual = reader.read_single.header

      assert_equal(expected, actual)
    }
  end
end
