require_relative 'mcp3208'
require_relative 'kty81'

# This class reads the temperature from a KTY81 chip.
# The KTY81 is a resistor with a temperature dependent resistance.
# The circuit consist of a constant resistor R in line with the temperature sensor T.
# With the measurement of the voltage over T (Ut) the resistance of T (Rt) is calculated.
# With resistance of T we know the temperature.
#
#   ___     _______ + Vtotal
#    |      |
# Ur |     [ ]  R
#    |      |
#   ---     |______ AD converter
#   ---     |
#    |      |
# Ut |     [ ]  T (KTY81)
#    |      |
#   ---     --------- -
#

class Temperature_Sensor

  def initialize(calibration = 0, u_total=3.3, resistance_r = 1200)
    @u_total = u_total
    @r_r = resistance_r
    if calibration.nil? do
      @calibration = 0
    end
    else
      @calibration = calibration
    end
    @ad_converter= MCP3208.new(@u_total)
    @temperature_sensor = KTY81_220.new
  end

  def read_sensor(channel = 0)

    u_sum = 0
    50.times {
        u_sum = u_sum + @ad_converter.read_value(channel)
    }
    u_t = u_sum / 50.0
    # u_t = 2.0  # Value for testing
    r_t = calculate_resistance(u_t)

    @temperature_sensor.to_temp(r_t)
  end

  private
    def calculate_resistance(u_t)
      # U = Ur + Ut
      u_r = @u_total - u_t
      # R = U / I -> I = U / R
      i = u_r / @r_r.to_f
      r_t = u_t / i + @calibration
      $LOG.debug "Voltage sensor: %f, Resistance sensor: %f " % [u_r, r_t]
      r_t
    end


end