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
      
      Header = lambda{|header_data|
        @@logger.info('Analyzer::execute : Header')
        
        result = { :page_size => extraction(header_data) }
        
        @@logger.debug(result)
        result
      }
      Body = lambda{|body_data|
        @@logger.info('Analyzer::execute : Body')
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
      Footer = lambda{|footer_data|
        @@logger.info('Analyzer::execute : Footer')
        footer_ext = lambda{|mark|
          footer_data.match(/[0-9]+ ?#{mark}/)[0].gsub(/[^0-9]+/, "").to_i
        }
        
        result = {
          :cache    => footer_ext.call('lookups'),
          :hits     => footer_ext.call('hits'),
          :hit_rate => footer_ext.call('\% hit rate')
        }
        @@logger.debug(result)
        result
      }
      All = lambda{|read_data|
        @@logger.info('Analyzer::execute : All')
        
        header = Header.call(read_data.header)
        body = Body.call(read_data.body)
        footer = Footer.call(read_data.footer)
        
        result = {}.merge(header).merge(body).merge(footer)
        @@logger.debug(result)
        result
      }
      
      private
      def self.extraction(str)
        str.gsub(/[^0-9]/, "").to_i
      end
    end
    
    def self.execute(read_data, part = Part::All)
      @@logger.info(AppLogger::delimiter)
      @@logger.info('Analyzer::execute start')
      
      if read_data.nil? || read_data.empty? then
        @@logger.info('Analyzer::execute data is empty. finish')
        return {}
      end
      
      result = part.call(read_data)
      @@logger.info('Analyzer::execute finish')
      result
    end
  end
end