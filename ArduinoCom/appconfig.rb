require 'logger'
require_relative "configreader"

require 'rubygems'
require "serialport"

class AppConfig
  @@config=nil
  def self.load
    if @@config.nil?
      @@config = ConfigReader.new("arduinocom",["arduinocom.conf"])
      @@config.load
    end
    
    def self.getloggerConfig
      self.load
      file = @@config['logger']['file']
      rotation = @@config['logger']['rotation']
      return file, rotation
      
    end
    
    def self.getArduino
      self.load
      
    end
  end
end