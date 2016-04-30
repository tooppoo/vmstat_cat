#encoding: utf-8

require 'logger'

module VmstatCat
  module Config
    test_mode = $0 == __FILE__
    check_require_path = lambda{|timing|
      puts "#{timing}-----------------------"
      puts $:
      puts "--------------------------------"
    }
    check_require_path.call('before') if test_mode
    $: << File::expand_path(__dir__)
    check_require_path.call('after') if test_mode
    
    module Logger
      @logger = nil
      def get
        @logger ||= Logger.new(File::expand_path("../log/log_${get_today}", __dir__))
        @logger.level = Logger::DEBUG
        @logger
      end
      
      def get_today
        today = Date.today
        
        y = today.year.to_s
        m = format("%02d", today.month)
        d = format("%02d", today.day)
        
        y + m + d
      end
    end
  end
end