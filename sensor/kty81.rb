require 'logger'

class KTY81_220

  RESISTANCE_TABLE = [
      {:r => 980,  :temp => -55, :coeff => 0.99},
      {:r => 1030, :temp => -50, :coeff => 0.98},
      {:r => 1135, :temp => -40, :coeff => 0.96},
      {:r => 1247, :temp => -30, :coeff => 0.93},
      {:r => 1367, :temp => -20, :coeff => 0.91},
      {:r => 1495, :temp => -10, :coeff => 0.88},
      {:r => 1630, :temp => 0,   :coeff => 0.85},
      {:r => 1772, :temp => 10,  :coeff => 0.83},
      {:r => 1922, :temp => 20,  :coeff => 0.80},
      {:r => 2000, :temp => 25,  :coeff => 0.79},
      {:r => 2080, :temp => 30,  :coeff => 0.78},
      {:r => 2245, :temp => 40,  :coeff => 0.75},
      {:r => 2417, :temp => 50,  :coeff => 0.73},
      {:r => 2597, :temp => 60,  :coeff => 0.71},
      {:r => 2785, :temp => 70,  :coeff => 0.69},
      {:r => 2980, :temp => 80,  :coeff => 0.67},
      {:r => 3182, :temp => 90,  :coeff => 0.65},
      {:r => 3392, :temp => 100, :coeff => 0.63},
      {:r => 3607, :temp => 110, :coeff => 0.59},
      {:r => 3817, :temp => 120, :coeff => 0.53},
      {:r => 3915, :temp => 125, :coeff => 0.49},
      {:r => 4008, :temp => 130, :coeff => 0.44},
      {:r => 4166, :temp => 140, :coeff => 0.33},
      {:r => 4280, :temp => 150, :coeff => 0.20}
  ]

  # Translate the measured capacity to a temperature value according to the
  # translation values from the data sheet of the sensor.
  #
  # returns the temperature in °C (rounded)
  def to_temp(resistance)
    $LOG.debug("resistance = " << resistance.to_s)

    entry = RESISTANCE_TABLE.bsearch {|x| x[:r] >= resistance}
    return "Error: Resistance to high" if entry.nil?
    r = entry[:r]
    $LOG.debug("Calculate with reference resistance " << r.to_s)
    delta = resistance - r
    delta_in_percentage = delta * 100.0 / r

    (entry[:temp] + delta_in_percentage / entry[:coeff]).round
  end
end
