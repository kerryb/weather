defmodule WeatherFirmware.Sensors.WindVaneTest do
  use ExUnit.Case, async: true

  alias WeatherFirmware.Sensors.WindVane

  @mapping %{
    0 => 0.875,
    22.5 => 0.582,
    45 => 0.635,
    67.5 => 0.159,
    90 => 0.175,
    112.5 => 0.127,
    135 => 0.318,
    157.5 => 0.230,
    180 => 0.453,
    202.5 => 0.400,
    225 => 0.772,
    247.5 => 0.750,
    270 => 0.962,
    292.5 => 0.899,
    315 => 0.932,
    337.5 => 0.823
  }

  setup %{test: test} do
    # Start a server named to match the test, to guarantee uniqueness
    {:ok, wind_vane} = WindVane.start_link(test)
    {:ok, wind_vane: wind_vane}
  end

  describe "WeatherFirmware.Sensors.WindVane.direction/1" do
    for {degrees, volts} <- @mapping do
      @degrees degrees
      @volts volts
      test "returns #{@degrees} for a voltage slightly under #{@volts}", %{wind_vane: wind_vane} do
        assert WindVane.direction(wind_vane, fn ^wind_vane -> @volts * 1023 * 0.99 end) ==
                 @degrees
      end

      test "returns #{@degrees} for a voltage slightly over #{@volts}", %{wind_vane: wind_vane} do
        assert WindVane.direction(wind_vane, fn ^wind_vane -> @volts * 1023 * 1.01 end) ==
                 @degrees
      end
    end
  end
end
