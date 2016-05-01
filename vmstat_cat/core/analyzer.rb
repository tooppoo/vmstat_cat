#encoding: utf-8

require_relative File::expand_path('./app_logger', __dir__)
require 'singleton'

module VmstatCat
  # 静的メンバしか持たないため、単一オブジェクトとする。
  class Analyzer
    include Singleton
    
    @@logger = AppLogger::get
    
    module Part
      @@logger = AppLogger::get
      
      Header = lambda{|analyzed_data|
        @@logger.info('Analyzer::execute : Header')
        
        result = { :page_size => extraction(analyzed_data.header) }
        
        @@logger.debug(result)
        result
      }
      Body = lambda{|analyzed_data|
        @@logger.info('Analyzer::execute : Body')
        body_data = analyzed_data.body
        
        result = {
          :free               => extraction(body_data[0]),
          :active             => extraction(body_data[1]),
          :inactive           => extraction(body_data[2]),
          :speculative        => extraction(body_data[3]),
          :wired_down         => extraction(body_data[4]),
          :translation_faults => extraction(body_data[5]),
          :copy_on_write      => extraction(body_data[6]),
          :zero_filled        => extraction(body_data[7]),
          :reactivated        => extraction(body_data[8]),
          :pageins            => extraction(body_data[9]),
          :pageouts           => extraction(body_data[10])
        }
        @@logger.debug(result)
        result
      }
      Footer = lambda{|analyzed_data|
        @@logger.info('Analyzer::execute : Footer')
        
        footer_ext = lambda{|mark|
          analyzed_data.footer.match(/[0-9]+ ?#{mark}/)[0].gsub(/[^0-9]+/, "").to_i
        }
        
        result = {
          :cache    => footer_ext.call('lookups'),
          :hits     => footer_ext.call('hits'),
          :hit_rate => footer_ext.call('\% hit rate')
        }
        @@logger.debug(result)
        result
      }
      All = lambda{|analyzed_data|
        @@logger.info('Analyzer::execute : All')
        
        header = Header.call(analyzed_data)
        body = Body.call(analyzed_data)
        footer = Footer.call(analyzed_data)
        
        result = {}.merge(header).merge(body).merge(footer)
        @@logger.debug(result)
        result
      }
      
      private
      def self.extraction(str)
        str.gsub(/[^0-9]/, "").to_i
      end
    end
    
    def self.execute(analyzed_data, part = Part::All)
      @@logger.info(AppLogger::delimiter)
      @@logger.info('Analyzer::execute start')
      
      if analyzed_data.nil? || analyzed_data.empty? then
        @@logger.info('Analyzer::execute data is empty. finish')
        return {}
      end
      
      result = part.call(analyzed_data)
      @@logger.info('Analyzer::execute finish')
      result
    end
  end
end