require 'logger'
require 'pathname'
require 'mqtt'
require 'yaml'
require 'em/pure_ruby'
require 'eventmachine'
require 'em/mqtt'
require 'json'
require_relative 'sensor/temperature_sensor'


class Greenhouse

  LOGGER_PATTERN = '%d %-5l %c: %m\n'
  CSV_PATTERN = '%d;%m\n'

  def initialize(config_file_name = 'config.yml')
    load_config config_file_name
    $LOG = Logger.new(@config['logfile'], 'daily')
    $LOG.info 'Greenhouse started'
    @csv = Logger.new(@config['csvfile'], 'monthly')
    @csv.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime('%Y-%m-%d %H:%M:%S')};#{msg}\n"
    end
  end

  def run
    interval = @config['interval'] || 60
    $LOG.debug @config
    while true
      begin
        EventMachine.run do
          server = @config['server']
#           @c = EventMachine::MQTT::ClientConnection.connect(:host => server['host'], :port => server['port'],
#                                                             :username => server['username'],
#                                                             :password => server['password'])
#           @c.subscribe(server['command_topic'])
#           @c.receive_callback do |message|
#               @logger.info "receive message #{message}"
#          end
          EventMachine::PeriodicTimer.new(interval) do
            begin
              read_sensors
            rescue => e
              $LOG.warn "Error reading sensors #{e.to_s}. Ignoring..."
            end
          end
        end
      rescue => e
        # Happens for example after reconnect to WiFi. Eventmachine throws error here
        $LOG.warn "Error occurred: #{e.to_s}. Ignoring and start again..."
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
    values = {}
    @config['sensors'].each do |sensor|
      $LOG.debug "Try to read sensor #{sensor['name']} with calibration #{sensor['calibration']}"
      temperature = Temperature_Sensor.new(sensor['calibration']).read_sensor(sensor['channel'])
      $LOG.debug "Sensor #{sensor['name']} has temperature #{temperature}"
      #$LOG.debug @c
      values[sensor['name']] = temperature
      @csv.info("#{sensor['name']};#{temperature}")
    end
    #@c.publish(@config['telemetry_topic'], JSON.generate(values))
  end
end

g = Greenhouse.new
g.run

