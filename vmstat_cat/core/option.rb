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
      @opt.on('-d VAL') {|v|
        @dir = v
      }
    end
  end
end