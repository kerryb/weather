defmodule WeatherFirmware.Sensors.EnvironmentTest do
  @moduledoc """
  Test for WeatherFirmware,Sensors.Environment.

  Uses the dummy Bme280 implementation in `test.support`.
  """

  use ExUnit.Case, async: true

  alias Bme280.Measurement
  alias WeatherFirmware.Sensors.Environment

  setup %{test: test} do
    # Start a server named to match the test, to guarantee uniqueness
    {:ok, sensor} = Environment.start_link(test)
    {:ok, sensor: sensor}
  end

  test "returns the latest value for humidity", %{sensor: sensor} do
    assert Environment.humidity(sensor) == 78.90
  end

  test "returns the latest value for pressure", %{sensor: sensor} do
    assert Environment.pressure(sensor) == 45.67
  end

  test "returns the latest value for temperature", %{sensor: sensor} do
    assert Environment.temperature(sensor) == 12.34
  end

  test "updates its values when it receives the reply from requesting a measurement", %{
    sensor: sensor
  } do
    send(sensor, %Measurement{
      humidity: 50.00,
      pressure: 40.00,
      temperature: 30.00
    })

    assert Environment.humidity(sensor) == 50.00
    assert Environment.pressure(sensor) == 40.00
    assert Environment.temperature(sensor) == 30.00
  end
end
