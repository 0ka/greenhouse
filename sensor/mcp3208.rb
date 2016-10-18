require 'pi_piper'

# Read values from MCP 3208 analog digital converter
class MCP3208

  def initialize(v_ref)
    @v_ref = v_ref
  end

  # read value of 12 bits from selected channel of the DAC chip
  def readValue(channel = 0)

    PiPiper::Spi.begin do |spi|
      PiPiper::Spi.set_mode(0,1)

      # Setup the chip select behavior
      spi.chip_select_active_low(active_low = true, PiPiper::Spi::CHIP_SELECT_0)

      # Set the bit order to MSB
      spi.bit_order PiPiper::Spi::MSBFIRST

      # Set the clock divider to get a clock speed of 1MHz
      spi.clock 1000000

      # byte1 = 5 leading zeros, start bit, single ended mode, first bit of channel
      byte1 = (1 << 2) | (1 << 1) | (channel >> 2)
      # byte2 = 1st bit: bit 2 of channel, 2nd bit: bit 3 of channel, bit 3 to 7 will be ignored and can be zero
      byte2 = (channel << 6).modulo(256)
      # value of byte 3 is ignored and can be zero
      byte3 = 0

      # Activate the chip select
      result = spi.chip_select do
        # Do the SPI write
        spi.write(byte1, byte2, byte3)
      end

      output_code = result[1].modulo(16) << 8 | result[2]
      v_in = output_code * @v_ref / 4096.0
      return v_in

    end
  end

end