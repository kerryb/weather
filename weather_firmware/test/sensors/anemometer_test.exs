defmodule WeatherFirmware.Sensors.AnemometerTest do
  use ExUnit.Case, async: true
  alias WeatherFirmware.Sensors.Anemometer

  @pin Application.compile_env!(:weather_firmware, :pins).anemometer

  setup %{test: test} do
    # Start a server named to match the test, to guarantee uniqueness
    {:ok, anemometer} = Anemometer.start_link(test)
    {:ok, anemometer: anemometer}
  end

  test "calculates the instantaneous windspeed based on the interval between pulses (3Hz = 2m/s)",
       %{anemometer: anemometer} do
    send(anemometer, {:circuits_gpio, @pin, 10_000_000_000, 0})
    send(anemometer, {:circuits_gpio, @pin, 10_333_333_333, 0})
    assert_in_delta Anemometer.speed(anemometer), 2, 0.001
  end
end
