require 'minitest/autorun'
require_relative 'kty81'

class KTY81Test < MiniTest::Test

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    Logging.logger.root.level = :debug
    Logging.logger.root.appenders = Logging.appenders.stdout
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_resistance_without_interpolation
    kty = KTY81_220.new
    assert_equal (kty.to_temp (980)), -55
    assert_equal (kty.to_temp (2000)), 25
    assert_equal (kty.to_temp (4280)), 150
  end

  def test_resistance_with_linear_interpolation
    kty = KTY81_220.new
    # assert_equal (kty.to_temp (0)), -156

    res = 2000
    coeff = 0.79
    assert_equal 21, (kty.to_temp (res - res * coeff * 4.0 / 100.0))
    assert_equal 22, (kty.to_temp (res - res * coeff * 3.0 / 100.0))
    assert_equal 23, (kty.to_temp (res - res * coeff * 2.0 / 100.0))
    assert_equal 24, (kty.to_temp (res - res * coeff * 1.0 / 100.0))
    assert_equal 25, (kty.to_temp (res - res * coeff * 0.0 / 100.0))

    # new group
    res = 2080
    coeff = 0.78
    assert_equal 26, (kty.to_temp (res - res * coeff * 4.0 / 100.0))
    assert_equal 27, (kty.to_temp (res - res * coeff * 3.0 / 100.0))
    assert_equal 28, (kty.to_temp (res - res * coeff * 2.0 / 100.0))
    assert_equal 29, (kty.to_temp (res - res * coeff * 1.0 / 100.0))
    assert_equal 30, (kty.to_temp (res - res * coeff * 0.0 / 100.0))

    # new group
    res = 2245
    coeff = 0.75
    assert_equal 31, (kty.to_temp (res - res * coeff * 9.0 / 100.0))
    assert_equal 32, (kty.to_temp (res - res * coeff * 8.0 / 100.0))
    assert_equal 33, (kty.to_temp (res - res * coeff * 7.0 / 100.0))
    assert_equal 34, (kty.to_temp (res - res * coeff * 6.0 / 100.0))
    assert_equal 35, (kty.to_temp (res - res * coeff * 5.0 / 100.0))
    assert_equal 36, (kty.to_temp (res - res * coeff * 4.0 / 100.0))
    assert_equal 37, (kty.to_temp (res - res * coeff * 3.0 / 100.0))
    assert_equal 38, (kty.to_temp (res - res * coeff * 2.0 / 100.0))
    assert_equal 39, (kty.to_temp (res - res * coeff * 1.0 / 100.0))
    assert_equal 40, (kty.to_temp (res - res * coeff * 0.0 / 100.0))
  end
end