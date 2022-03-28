defmodule WeatherFirmware.Sensors.RainGaugeTest do
  use ExUnit.Case, async: true
  alias WeatherFirmware.Sensors.RainGauge

  @pin Application.compile_env!(:weather_firmware, :pins).rain_gauge

  defmodule FakeClock do
    use Agent

    @spec start_link :: GenServer.on_start()
    def start_link do
      Agent.start_link(fn -> DateTime.utc_now() end, name: __MODULE__)
    end

    @spec utc_now :: DateTime.t()
    def utc_now do
      Agent.get(__MODULE__, & &1)
    end

    @spec set(DateTime.t()) :: :ok
    def set(date_time) do
      Agent.update(__MODULE__, fn _state -> date_time end)
    end
  end

  setup %{test: test} do
    {:ok, _fake_clock} = FakeClock.start_link()
    # Start a server named to match the test, to guarantee uniqueness
    {:ok, rain_gauge} = RainGauge.start_link(test, &FakeClock.utc_now/0)
    RainGauge.reset(rain_gauge)
    {:ok, rain_gauge: rain_gauge}
  end

  test "reports the rainfall in the preceding 60 minutes", %{rain_gauge: rain_gauge} do
    FakeClock.set(~U[2022-03-28 12:00:00Z])
    send(rain_gauge, {:circuits_gpio, @pin, 100, 0})
    # read value to ensure message has been handled
    assert_in_delta RainGauge.hourly_rainfall(rain_gauge), 0.2794, 0.00001

    FakeClock.set(~U[2022-03-28 12:15:00Z])
    send(rain_gauge, {:circuits_gpio, @pin, 200, 0})
    assert_in_delta RainGauge.hourly_rainfall(rain_gauge), 0.5588, 0.00001

    FakeClock.set(~U[2022-03-28 13:00:00Z])
    send(rain_gauge, {:circuits_gpio, @pin, 300, 0})
    assert_in_delta RainGauge.hourly_rainfall(rain_gauge), 0.5588, 0.00001
  end
end
