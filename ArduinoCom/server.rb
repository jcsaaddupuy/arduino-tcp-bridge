require 'socket'                # Get sockets from stdlib
require 'logger'

require 'rubygems'
require "serialport"

MUTEX_RW = Mutex.new
MUTEX_KILL_CLIENTS = Mutex.new

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG


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
    @server = TCPServer.open(20000)   # Socket to listen on port 2000
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
    puts line.chop      # And print with platform line terminator
    #TODO write to arduino
    writeToArduino line.chop
  end
 end
 
  def writeToClient(data)
   LOG.debug "Trying to send #{data} to clients"
    MUTEX_KILL_CLIENTS.synchronize{ 
     @clients.each { |client|
      begin
        client.write data
      rescue
        @clientsToClose << client
      end
      }
    }
    deleteBadClient
 end

  def openArduino
    port_str = "/dev/ttyACM0"  #may be different for you
    baud_rate = 115200
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    
    @arduino = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    LOG.info "Arduino open"
  end
  
  def readFromArduino()
   LOG.info "Trying to read from Arduino"
  
   while !@stopped do  # Read lines from the socket
     MUTEX_RW.synchronize{
       line = @arduino.gets
       if !line.nil?
        LOG.info line      # And print with platform line terminator  
        writeToClient(line)
       end
     }
  end
 end
 
 def writeToArduino(data)
   LOG.debug "Writing to Arduino '#{data}'"
   MUTEX_RW.synchronize{
    @arduino.puts data
   }
 end
 

  def deleteBadClient
    MUTEX_KILL_CLIENTS.synchronize{
    @clientsToClose.each { |client|
      @clients.delete(client)
      }
    }
  end
end

s = Server.new
s.start
#sleep 30
#s.stop
