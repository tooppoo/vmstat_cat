#encoding: utf-8

require_relative File::expand_path('../../../', __FILE__) + '/core/config'

require 'test/unit'
require 'io/vmstat_writer'

include VmstatCat::IO

class TestVmstatWriter < Test::Unit::TestCase
  def setup
    @output_name = File::expand_path('../../../', __FILE__) + '/out/test/result.csv'
    @writer = VmstatWriter.new(@output_name)
  end
  
  def test_dir
    expected = File::dirname(@output_name)
    actual = @writer.dir
    
    assert_equal(expected, actual)
  end
  
  def test_name
    expected = 'result.csv'
    actual = @writer.name
    
    assert_equal(expected, actual)
  end
  
  def test_write
    sample = {
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
    @writer.write(sample)
    sample[:page_size] = 5096
    @writer.write(sample)
    
    assert_equal(true, Dir::exist?(File::dirname(@output_name)))
  end
end
