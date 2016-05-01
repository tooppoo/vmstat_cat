#encoding: utf-8

require_relative File::expand_path('./app_logger', __dir__)

require 'optparse'
require 'singleton'

module VmstatCat
  class Option
    include Singleton
    
    DEFAULT_PATH = File::expand_path('../../out', __FILE__) + '/result.csv'
    
    @@logger = AppLogger::get
    
    attr_reader :dir
    
    def initialize
      @opt = OptionParser.new
      @dir = DEFAULT_PATH
      
      set_option
      design_usage
    end
    
    def parse(args)
      @@logger.info(AppLogger::delimiter)
      @@logger.info('Option#parse start')
      @@logger.debug("Option#parse args : #{args}")
      
      result = @opt.parse(args)
      
      @@logger.debug("Option#parse result : #{result}")
      @@logger.debug("Option#dir : #{@dir}")
      @@logger.info('Option#parse finish')
      result
    end
    
    private 
    def set_option
      @opt.on('-o', '--output=VAL', '出力先のパスを指定する') {|v|
        @dir = v
      }
    end
    
    def design_usage
      @opt.banner = 'Usage: ruby main.rb src [output]'
      @opt.on_head(
        'src: vm_statのログが記載されたテキストファイル',
        ''
      )
      @opt.on_tail(
        'example:',
        'ruby main.rb ./sample/sample.log',
        'ruby main.rb ./sample/sample.log -o ./out/result.csv'
      )
    end
  end
end