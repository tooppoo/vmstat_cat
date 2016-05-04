#encoding: utf-8

require_relative File::expand_path('./config', __dir__)

require 'app_logger'
require 'singleton'

module VmstatCat
  # 静的メンバしか持たないため、単一オブジェクトとする。
  class Analyzer
    include Singleton
    
    @@logger = AppLogger::get
    
    module Part
      @@logger = AppLogger::get
      
      Header = lambda{|read_data|
        @@logger.info('Analyzer::execute : Header')
        
        result = { :page_size => extraction(read_data.header) }
        
        @@logger.debug(result)
        result
      }.freeze
      Body = lambda{|read_data|
        @@logger.info('Analyzer::execute : Body')
        body_data = read_data.body
        
        result = {}
        
        read_data.body.each{|data|
          key = data.match(/.+:/)[0].gsub(":", "")
          value = data.match(/[0-9]+/)[0]
          
          @@logger.debug("key:#{key}")
          @@logger.debug("value:#{value}")
          
          result[key.to_s.to_sym] = value.to_s
        }

        @@logger.debug(result)
        result
      }.freeze
      Footer = lambda{|read_data|
        @@logger.info('Analyzer::execute : Footer')
        
        unless Config::FOOTER_EXISTS then
          @@logger.info('Analyzer::execute : Footer doesn`t exist')
          return {}
        end
  
        footer_ext = lambda{|mark|
          matched = read_data.footer.match(/[0-9]+ ?#{mark}/)
          matched.nil? ? "" : matched[0].gsub(/[^0-9]+/, "").to_i
        }
        
        result = {
          :cache    => footer_ext.call('lookups'),
          :hits     => footer_ext.call('hits'),
          :hit_rate => footer_ext.call('\% hit rate')
        }
        @@logger.debug(result)
        result
      }.freeze
      All = lambda{|read_data|
        @@logger.info('Analyzer::execute : All')
        
        header = Header.call(read_data)
        body = Body.call(read_data)
        footer = Footer.call(read_data)
        
        result = {}.merge(header).merge(body).merge(footer)
        @@logger.debug(result)
        result
      }.freeze
      
      private
      def self.extraction(str)
        str.gsub(/[^0-9]/, "").to_i
      end
    end
    Part.freeze
    
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