#encoding: utf-8

require_relative File::expand_path('./core/config', __dir__)

require 'io/vmstat_reader'
require 'io/vmstat_writer'
require 'analyzer'
require 'option'
require 'error'
require 'app_logger'

return unless $0 == __FILE__

  include VmstatCat
  include VmstatCat::IO
  
class Main
  
  def initialize
    opt = Option.instance
    args = opt.parse(ARGV)
    
    @src_log = args[0]
    @out_dir = opt.dir
    
    puts "整形するログファイル     : #{File::expand_path(@src_log)}"
    puts "整形したファイルの出力先 : #{@out_dir}"
    
    raise SrcLogError.new('整形するログファイルが指定されていません') if @src_log.nil? || @src_log.length == 0
    raise SrcLogError.new('指定されたログファイルが見つかりません') unless File::exists?(@src_log)
  end
  
  def read
    puts "ログファイル読込 : 開始"
    result = []
    
    VmstatReader.new(@src_log).each{|reader|
      result << reader.read_single
    }
    puts "ログファイル読込 : 完了"
    result
  end
  
  def analyze(raw_data_list)
    puts "データ解析 : 開始"
    result = []
    indicator = Indicator.new(raw_data_list.length)
    
    raw_data_list.each_with_index{|val, idx|
      result << Analyzer::execute(val)
      indicator.show_progress(idx + 1)
    }
    puts "データ解析 : 完了"
    
    result
  end
  
  def write(analyzed_data)
    puts "解析データ出力 : 開始"
    writer = VmstatWriter.new(@out_dir)
    indicator = Indicator.new(analyzed_data.length)
    index = 0
    
    analyzed_data.each{|val|
      writer.write(val)
      indicator.show_progress(index += 1)
    }
    puts "解析データ出力 : 完了"
  end
  
  class Indicator
    attr_reader :size
    
    def initialize(size, unit = 80)
      @size = size
      @unit = size / unit
      @index = 1
    end
    
    def show_progress(current)
      # size == 8000 && unit = 80の場合、100件完了していたら表示を進める。
      # 2つ目を表示する時は200件完了、3つ目は300件完了・・・となる。
      if current > @unit * @index then
        print '*'
        @index += 1
      end
      if current >= @size then
        # 処理が完了したら改行
        puts ''
      end
    end
  end
end

begin
  main = Main.new

  raw_data = main.read
  analyzed = main.analyze(raw_data)
  main.write(analyzed)
rescue SrcLogError => e
  puts e.message
rescue OptionParser::ParseError => e
  puts "不正なオプションが指定されました。"
  puts e.message
rescue => e
  logger = AppLogger::get
  
  puts "予期しないエラーが発生しました"
  
  logger.error(e.message)
  logger.error(e.cause)
  logger.error(e.backtrace)
end