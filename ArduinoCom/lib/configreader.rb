require 'logger'

require 'rubygems'
require 'parseconfig'


# Hacking Parseconfig pour récupérer les parametres directement sous forme de hash
# definition de la methode to_h 
class ParseConfig
  def to_h
    return self.params #Hash contenant les entrees clefs/valeur du fichier de config
  end
end

LOG = Logger.new(STDOUT)
LOG.level = Logger::DEBUG

current_folder =  File.expand_path(File.dirname(__FILE__))

CONFIG_FILES = ["arduinocom.conf"]
CONFIG_FOLDERS = [current_folder+"/../conf","/etc/default/arduinocom", "~/.config/arduinocom"]


class ConfigReader
   @@config_file_found=0
   @@loaded = false
   @@conffigs={}
   @@mainconfig={}
    def loadConfig
      CONFIG_FOLDERS.each { |folder|
        CONFIG_FILES.each {|file|
            full_filename =  File.expand_path(folder + "/" + file)
            LOG.debug "Trying file #{full_filename}"
            exist = File.exist?(full_filename)
            if exist 
              LOG.debug "File #{full_filename}"
              config = loadFile(full_filename)
              @@conffigs[full_filename]=config
              @@config_file_found+=1  
            end 
          }
      }
    end  
    
    def loadFile(fname)
      LOG.debug "Loading #{fname}"
      return ParseConfig.new(fname)
    end
    
    def merge
      @@conffigs.each { |config_key, config_value|
        puts config_value.get_params()
        @@mainconfig.merge! config_value.to_h    
      }
    end
    
    def load
      if !@@loaded
        loadConfig
        merge
        puts @@mainconfig
        @@loaded=true
      end
    end
end

c = ConfigReader.new
c.load

