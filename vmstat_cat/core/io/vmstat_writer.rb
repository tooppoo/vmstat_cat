#encoding: utf-8

require 'fileutils'
require 'csv'

module VmstatCat
  module IO
    class VmstatWriter
      
      attr_reader :dir
      
      def initialize(output_path)
        output_path = File::expand_path(output_path)
        
        @ext = File::extname(output_path)
        @name = File::basename(output_path, @ext)
        @dir = File::dirname(output_path)
        
        # 同じVmstatWriterを使い回す限り、@created_atの値は不変。
        # => 一つのインスタンスのwrite()を実行する限り、出力先ファイルは一定。
        @created_at = set_created_at
        @first_writing = true
      end
      
      def name
        @name + @ext
      end
      
      def write(vmstat_record)
        ensure_directory
        
        Dir::chdir(@dir) {
          csv_config = {
            :headers => true,
            :write_headers => true
          }
          
          CSV::open("#{@name}_#{@created_at}#{@ext}", 'a+:utf-8', csv_config){|file|
            # インスタンス生成後、始めてwriteを実行する時(＝まだヘッダーが記入されていない時)のみ、
            # ヘッダーを記入する。
            file << vmstat_record.keys if @first_writing
            file << vmstat_record.values
          }
        }
        @first_writing = false
      end
      
      private
      def ensure_directory
        unless Dir::exist?(@dir) then
          FileUtils::mkdir_p(@dir)
        end
      end
      
      def set_created_at
        fill_0 = lambda{|val|
          format("%02d", val)
        }
        oclock = Time.now
        
        y = oclock.year.to_s
        m = fill_0.call(oclock.month)
        d = fill_0.call(oclock.day)
        
        h = fill_0.call(oclock.hour)
        mi = fill_0.call(oclock.min)
        s = fill_0.call(oclock.sec)
        
        "#{y + m + d}_#{h + mi + s}"
      end
    end
  end
end