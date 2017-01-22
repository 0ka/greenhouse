require 'logging'
require 'pathname'
require 'mqtt'
require 'yaml'
require 'em/pure_ruby'
require 'eventmachine'
require 'em/mqtt'
require_relative 'sensor/temperature_sensor'


class Greenhouse

  LOGGER_PATTERN = '%d %-5l %c: %m\n'

  def initialize(config_file_name = 'config.yml')
    Logging.logger.root.level = :debug
    load_config config_file_name
    Logging.logger.root.appenders = Logging.appenders.rolling_file(
        '/tmp/greenhouse.log',
        :layout => Logging.layouts.pattern(:pattern => LOGGER_PATTERN))
    @logger = Logging.logger[self]
    @logger.info 'Greenhouse started'
  end

  def run
    interval = @config['interval'] || 60
    @logger.debug @config
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
    config_path = resolve_relative_path(config_file_name)
    config_file = File.new config_path
    @config = YAML.load config_file.read
  end

  def resolve_relative_path(config_file_name)
    if Pathname(config_file_name).relative?
      config_path = File.dirname(__FILE__) + '/' + config_file_name
    else
      config_path = config_file_name
    end
    config_path
  end

  def read_sensors
    @config['sensors'].each do |sensor|
      temperature = Temperature_Sensor.new.read_sensor(sensor['channel'])
      @logger.debug "Sensor #{sensor['name']} has temperature #{temperature}"
      @logger.debug @c
      @c.publish(sensor['name'], temperature)
    end
  end
end

g = Greenhouse.new
g.run

