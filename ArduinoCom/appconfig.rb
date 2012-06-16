require 'logger'

require_relative "lib/configreader"

require 'rubygems'
require "serialport"

class AppConfig
  @@cr=nil
  @@config=nil
  def self.load
    if @cr.nil?
      @@cr = ConfigReader.new("arduinocom",["arduinocom.conf"])
    end
    if @@config.nil?
     @@config = @@cr.load
    end

  end

  def self.getloggerConfig
    self.load
    file = @@config['logger']['file']
    rotation = @@config['logger']['rotation']
    level = Logger::DEBUG #TODO move to conf
    return file, rotation, level

  end

  def self.getArduinoConfig
    self.load
    port_str = @@config['adruino']['serial_port']  #may be different for you
    baud_rate = Integer(@@config['adruino']['baud_rate'])
    data_bits = Integer(@@config['adruino']['data_bits'])
    stop_bits = Integer(@@config['adruino']['stop_bits'])

    parity = SerialPort::NONE
    return port_str, baud_rate, data_bits, stop_bits, parity
  end

  def self.getServerConfig
    self.load
    bind_to = @@config['tcp_server']['bind_to']
    port = Integer(@@config['tcp_server']['port'])
    return bind_to,port

  end

end