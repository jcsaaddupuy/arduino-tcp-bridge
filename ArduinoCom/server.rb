require 'socket'                # Get sockets from stdlib
require 'logger'

require 'rubygems'
require "serialport"

require_relative "appconfig" 

logfile, logrotation , loglevel = AppConfig.getloggerConfig
LOG=Logger.new(logfile, logrotation )
LOG.level = loglevel


class Server
  attr_accessor :stopped,:clients, :arduino
  
  def initialize
    @clients=Array.new
    @clientsToClose=Array.new
    @server=nil
    @stopped=false
    @arduino=nil
  end
  
  def start
    openArduino 
    tArduino = Thread.new{ self.readFromArduino }
    tArduino.abort_on_exception = true
    bind_to, port = AppConfig.getServerConfig 
    
    @server = TCPServer.open(port)   # Socket to listen on port 2000
    t1 = Thread.new { self.acceptClients }
    t1.abort_on_exception = true
    t1.join
    tArduino.join
    
  end
  
  def acceptClients
     while !@stopped do
        client = @server.accept
        
        @clients << client
        LOG.info "Accepted new client"
        tRead = Thread.new { self.readFromClient(client) }
        tRead.abort_on_exception = true
     end
  end
  
  def stop
    @stopped=true
    LOG.info "Stop"
    self.doStop
  end  
  
 def doStop
  LOG.info "Closing all clients"
  @clients.each { |client|
    if !client.closed?
      client.puts "Bye!"
      client.flush
      client.close
    end
  } 
 end
  
 def readFromClient(client)
   while line = client.gets   # Read lines from the socket
    LOG.debug "Readed from client '#{line.strip}'"      # And print with platform line terminator
    writeToArduino line.strip
  end
 end
 
  def writeToClient(data)
   LOG.debug "Trying to send '#{data.strip}' to clients" 
     @clients.each { |client|
      begin
        client.write data
      rescue
        @clientsToClose << client
      end
      }
    deleteBadClient
 end

  def openArduino
    port_str,baud_rate,data_bits,stop_bits,parity = AppConfig.getArduinoConfig
    
    @arduino = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    LOG.info "Arduino open"
  end
  
  def readFromArduino()
   LOG.info "Trying to read from Arduino"
  
   while !@stopped do  # Read lines from the socket
       line = @arduino.gets
       if !line.nil?
        LOG.info line      # And print with platform line terminator  
        writeToClient(line)
       end
  end
 end
 
 def writeToArduino(data)
   LOG.debug "Writing to Arduino '#{data.strip}'"
    @arduino.puts data.strip
 end
 

  def deleteBadClient
    @clientsToClose.each { |client|
      @clients.delete(client)
      }
  end
end

s = Server.new
s.start

