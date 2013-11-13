arduino-tcp-bridge
==================

This tool make a tcp-to-serial bridge to communicate to an arduino wih multiples clients.

It does just writes anything that come on the server sockets to the arduino an write to sockets clients
anythings that is readed from the arduino.

Compatibility
-------------
Developped and tested with ruby 1.9.2. Not tested with upper version, something may break :)


Install it
-----------
``bash
bundle install
``

Configure it
-------------
Configuration is located in conf/arduino-tcp-bridge/arduino-tcp-bridge.conf
The config file can be copyed to ~/.config/arduino-tcp-bridge/ or in /etc/default/arduino-tcp-bridge/.

Thes file ill be readed in this order :
- local config file (in conf/arduino-tcp-bridge/)
- system wide configuration (in /etc/default/arduino-tcp-bridge/)
- current user configuration (in ~/.config/arduino-tcp-bridge/)

These file will be merged, so you can put a arduino-tcp-bridge.conf in these location with just the changes you need.
Only the first is mandatory.

By default :
- the daemon bind to 0.0.0.0 on the port 20000
- the serial communication is established throught /dev/ttyACM0



Run it
-------
Thanks to the gem daemons, the script can be run as a service :
``bash
ruby arduino-tcp-bridge.rb start # will fork in the background
ruby arduino-tcp-bridge.rb run # will stay in the foreground

ruby arduino-tcp-bridge.rb stop # stops the daemon
``

Test it
-------
``bash
telnet thebridge 20000 # replace the bridge with your host
rying 192.168.0.7...
Connected to arduino.lan.
Escape character is '^]'.
something you want to forward; #This is sent to the arduino.
3,Unknown command;            # This is readed from the arduino.
``

Logs
-------
Logs are by default located in '/tmp/log.txt'.

