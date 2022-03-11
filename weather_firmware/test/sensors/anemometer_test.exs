defmodule WeatherFirmware.Sensors.AnemometerTest do
  use ExUnit.Case, async: true
  alias WeatherFirmware.Sensors.Anemometer

  @pin Application.compile_env!(:weather_firmware, :pins).anemometer

  setup do
    # Start a server named to match this test module, to guarantee uniqueness
    {:ok, pid} = Anemometer.start_link(__MODULE__)
    {:ok, anemometer: pid}
  end

  test "calculates the instantaneous windspeed based on the interval between pulses (3Hz = 2m/s)",
       %{anemometer: anemometer} do
    send(anemometer, {:circuits_gpio, @pin, 10_000_000_000, 0})
    send(anemometer, {:circuits_gpio, @pin, 10_333_333_333, 0})
    assert_in_delta Anemometer.speed(__MODULE__), 2, 0.001
  end
end
