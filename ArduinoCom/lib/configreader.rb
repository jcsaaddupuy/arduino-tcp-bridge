require 'logger'

require 'rubygems'
require 'parseconfig'
require 'hash_deep_merge'

# Hacking Parseconfig pour récupérer les parametres directement sous forme de hash
# definition de la methode to_h 
class ParseConfig
  def to_h
    return self.params #Hash contenant les entrees clefs/valeur du fichier de config
  end
end

LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::DEBUG

current_folder =  File.expand_path(File.dirname(__FILE__))


CONFIG_FOLDERS = [current_folder+"/../conf","/etc/default/", "~/.config/"]


class ConfigReader
   @@loaded = false
   @@configs={}
   @@mainconfig={}
   
   @@config_files = []
   @@config_folders = []
   def initialize(appname,configfiles)
     @@config_files=configfiles
     CONFIG_FOLDERS.each { |folder|
        @@config_folders << folder+"/"+appname   
     }
   end
   
    def loadConfig
      @@config_folders.each { |folder|
        @@config_files.each {|file|
            full_filename =  File.expand_path(folder + "/" + file)
            LOGGER.debug "Trying file #{full_filename}"
            exist = File.exist?(full_filename)
            if exist 
              LOGGER.debug "File #{full_filename}"
              config = loadFile(full_filename)
              @@configs[full_filename]=config  
            end 
          }
      }
    end  
    
    def loadFile(fname)
      LOGGER.debug "Loading #{fname}"
      return ParseConfig.new(fname)
    end
    
    def merge
      @@configs.each { |config_key, config_value|
        @@mainconfig.deep_merge! config_value.to_h    
      }
    end
    
    def load
      if !@@loaded
        loadConfig
        merge
        @@loaded=true
      end
      @@mainconfig # return main config
    end
end



