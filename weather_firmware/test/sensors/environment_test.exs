defmodule WeatherFirmware.Sensors.EnvironmentTest do
  @moduledoc """
  Test for WeatherFirmware,Sensors.Environment.

  Uses the dummy Bme680 implementation in `test.support`.
  """

  use ExUnit.Case, async: true

  alias Bme680.Measurement
  alias WeatherFirmware.Sensors.Environment

  setup do
    # Start a server named to match this test module, to guarantee uniqueness
    {:ok, pid} = Environment.start_link(__MODULE__)
    {:ok, sensor: pid}
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
      gas_resistance: 10_000,
      humidity: 50.00,
      pressure: 40.00,
      temperature: 30.00
    })

    assert Environment.humidity(sensor) == 50.00
    assert Environment.pressure(sensor) == 40.00
    assert Environment.temperature(sensor) == 30.00
  end
end
