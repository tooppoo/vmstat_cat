#encoding: utf-8

module VmstatCat
  module IO
    class VmstatReader
      attr_reader :header, :footer, :body
      
      def initialize(file_path)
        File.open(file_path, 'r'){|f|
          @log_data = f.read.split("\n")
        }
        @header_index = 0
      end
      
      def read_single
        return nil unless has_next?
        
        header = @log_data[@header_index]
        body = @log_data[body_begin_index .. body_end_index]
        footer = @log_data[footer_index]
        
        @header_index = next_header_index
        
        ReadData.new(header, body, footer)
      end
      
      def has_next?
        @log_data.length > @header_index
      end
      
      class ReadData
        attr_reader :header, :body, :footer
        
        def initialize(header, body, footer)
          @header = header
          @body = Body.new(body)
          @footer = footer
        end
        
        class Body
          def initialize(body_data)
            @body_data = body_data
          end
          
          def [](index)
            @body_data[index]
          end
          
          def length
            @body_data.length
          end
        end
      end
      
      private
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