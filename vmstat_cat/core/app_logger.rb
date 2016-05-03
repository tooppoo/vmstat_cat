#encoding: utf-8

require_relative File::expand_path('./created_at', __dir__)
require 'logger'

module VmstatCat
  module AppLogger
    extend CreatedAt
    
    def self.get
      self::ensure_directory
      
      @@logger = Logger.new(File::expand_path("../log/log_#{created_at}.log", __dir__)) unless defined? @@logger
      @@logger.level = Logger::DEBUG
      
      @@logger
    end
    
    def self.delimiter(deli = '-', count = 80)
      deli * count
    end

    private
    def self.ensure_directory
      log_dir = File::expand_path('../log', __dir__)
      Dir::mkdir(log_dir) unless Dir::exists?(log_dir)
    end
  end
end