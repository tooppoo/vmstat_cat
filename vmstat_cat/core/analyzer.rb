#encoding: utf-8

require 'singleton'

module VmstatCat
  # 静的メンバしか持たないため、単一オブジェクトとする。
  class Analyzer
    include Singleton
    
    module Part
      Header = lambda{|header_data|
        { :page_size => extraction(header_data) }
      }
      Body = lambda{|body_data|
        {
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
      }
      Footer = lambda{|footer_data|
        footer_ext = lambda{|mark|
          footer_data.match(/[0-9]+ ?#{mark}/)[0].gsub(/[^0-9]+/, "").to_i
        }
        
        {
          :cache    => footer_ext.call('lookups'),
          :hits     => footer_ext.call('hits'),
          :hit_rate => footer_ext.call('\% hit rate')
        }
      }
      All = lambda{|read_data|
        header = Header.call(read_data.header)
        body = Body.call(read_data.body)
        footer = Footer.call(read_data.footer)
        
        {}.merge(header).merge(body).merge(footer)
      }
      
      private
      def self.extraction(str)
        str.gsub(/[^0-9]/, "").to_i
      end
    end
    
    def self.execute(read_data, part = Part::All)
      return {} if read_data.nil? || read_data.empty?
      
      part.call(read_data)
    end
  end
end