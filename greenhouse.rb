require 'logger'
require 'mqtt'
require 'yaml'
require 'em/pure_ruby'
require 'eventmachine'
require 'em/mqtt'
require_relative 'sensor/temperature_sensor'


class Greenhouse
  attr_accessor :logger

  def initialize(config_file_name = './config.yml')
    load_config config_file_name
    self.logger = Logger.new(STDOUT)
    self.logger.level = Logger::DEBUG
  end

  def run
    interval = @config['interval'] || 60
    logger.debug @config
    EventMachine.run do
      server = @config['server']
      @c = EventMachine::MQTT::ClientConnection.connect(server['host'], server['port'])
      @c.subscribe(server['command_topic'])
      @c.receive_callback do |message|
          p "receive message #{message}"
      end
      EventMachine::PeriodicTimer.new(interval) do
        read_sensors
      end
    end
  end

  def load_config(config_file_name)
    config_file = File.new config_file_name
    @config = YAML.load config_file.read
  end

  def read_sensors
    @config['sensors'].each do |sensor|
      temperature = Temperature_Sensor.new.read_sensor(sensor['channel'])
      logger.debug "Sensor #{sensor['name']} has temperature #{temperature}"
      logger.debug @c
      @c.publish(sensor['name'], temperature)
    end
  end
end

g = Greenhouse.new
g.run

