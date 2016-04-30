#encoding: utf-8

require_relative File::expand_path('../app_logger', __dir__)

module VmstatCat
  module IO
    @@logger = AppLogger::get
    
    class VmstatReader
      
      attr_reader :header, :footer, :body
      
      def initialize(file_path)
        @@logger.info('='*50)
        @@logger.info('VmstatReader#new start')
        @@logger.debug("arg/file_path : #{file_path}")
        
        File.open(file_path, 'r'){|f|
          @log_data = f.read.split("\n")
        }
        @header_index = 0
        @@logger.info('VmstatReader#new finish')
      end
      
      def read_single
        @@logger.info('VmstatReader#read_single start')
        
        unless has_next?
          @@logger.debug('next record doesn`t exist')
          @@logger.info('VmstatReader#read_single finish')
          return nil
        end
        result = create_read_data
        @@logger.info('VmstatReader#read_single finish')
        result
      end
      
      def has_next?
        @log_data.length > @header_index
      end
      
      def each(&block)
        while has_next? do
          block.call(self)
        end
      end
      
      class ReadData
        attr_reader :header, :body, :footer
        
        def initialize(header, body, footer)
          @@logger.info('ReadData#new start')
          
          @header = header.nil? ? "" : header
          @body = Body.new(body)
          @footer = footer.nil? ? "" : footer
          
          @@logger.debug("header : #{header}")
          @@logger.debug("body   : #{body}")
          @@logger.debug("footer : #{footer}")
          
          @@logger.info('ReadData#new finish')
        end
        
        def empty?
          @header.length == 0 || @body.empty? || @footer.length == 0
        end
        
        class Body
          attr_reader :length
          
          def initialize(body_data)
            @@logger.info('Body#new start')
            
            @body_data = body_data.nil? ? [] : body_data
            @length = @body_data.length
            
            @@logger.info('Body#new end')
          end
          
          def [](index)
            @body_data[index]
          end
          
          def empty?
            @length == 0
          end
        end
      end
      
      private
      def create_read_data
        header = @log_data[@header_index]
        body = @log_data[body_begin_index .. body_end_index]
        footer = @log_data[footer_index]
        
        @header_index = next_header_index
        
        result = ReadData.new(header, body, footer)
      end
      
      def footer_index
        @header_index + 12
      end
      
      def body_begin_index
        @header_index + 1
      end
      
      def body_end_index
        @header_index + 11
      end
      
      def next_header_index
        @header_index + 13
      end
    end
  end
end