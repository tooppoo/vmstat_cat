#encoding: utf-8

require_relative File::expand_path('../config', __dir__)

require 'fileutils'
require 'csv'
require 'app_logger'
require 'created_at'

module VmstatCat
  module IO
    class VmstatWriter
      include CreatedAt
      
      @@logger = AppLogger::get
      
      attr_reader :dir
      
      def initialize(output_path)
        @@logger.info(AppLogger::delimiter)
        @@logger.info('VmstatWriter#new start')
        
        output_path = File::expand_path(output_path)
        
        @ext = File::extname(output_path)
        @name = File::basename(output_path, @ext)
        @dir = File::dirname(output_path).freeze
        
        # 同じVmstatWriterを使い回す限り、@created_atの値は不変。
        # => 一つのインスタンスのwrite()を実行する限り、出力先ファイルは一定。
        @created_at = created_at
        @first_writing = true
        
        @@logger.debug("@ext  : #{@ext}")
        @@logger.debug("@name : #{@name}")
        @@logger.debug("@dir  : #{@dir}")
        
        @@logger.info('VmstatWriter#new finish')
      end
      
      def name
        @name + @ext
      end
      
      def write(vmstat_record)
        @@logger.info(AppLogger::delimiter)
        @@logger.info('VmstatWriter#write start')
        @@logger.debug("vmstat_record : #{vmstat_record}")
        
        ensure_directory
        
        Dir::chdir(@dir) {
          csv_config = {
            :headers => true,
            :write_headers => true
          }
          @@logger.debug("config : #{csv_config}")
          
          CSV::open("#{@name}_#{@created_at}#{@ext}", 'a+:utf-8', csv_config){|file|
            # インスタンス生成後、始めてwriteを実行する時(＝まだヘッダーが記入されていない時)のみ、
            # ヘッダーを記入する。
            if @first_writing then
              @@logger.info('writing vm_stat log first')
              file << vmstat_record.keys
            end
            file << vmstat_record.values
          }
        }
        @first_writing = false
        
        @@logger.debug("file_name : #{@name}_#{@created_at}#{@ext}")
        @@logger.info('VmstatWriter#write finish')
      end
      
      private
      def ensure_directory
        unless Dir::exist?(@dir) then
          @@logger.info('VmstatLogger#ensure_directory')
          @@logger.info('create dir')
          @@logger.debug(@dir)
          
          FileUtils::mkdir_p(@dir)
        end
      end
    end
  end
end