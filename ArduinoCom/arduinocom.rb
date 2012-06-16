#!/usr/bin/env ruby
#Just a kickstart to act as a daemon
 
require 'rubygems'        # if you use RubyGems
require 'daemons'

Daemons.run('server.rb')
Kernel.trap('INT') { Daemons.stop_all }
