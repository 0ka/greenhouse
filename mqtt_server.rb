require 'em/mqtt'

server = EventMachine::MQTT::Server.new
server.run