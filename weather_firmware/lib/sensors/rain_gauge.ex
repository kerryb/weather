defmodule WeatherFirmware.Sensors.RainGauge do
  @moduledoc """
  Interface to the rainfall gauge

  The sensor produces a pulse for every 0.2794mm of rain.
  """

  use GenServer, start: {__MODULE__, :start_link, []}
  alias Circuits.GPIO

  @pin Application.compile_env!(:weather_firmware, :pins).rain_gauge
  @seconds_to_keep 100_000
  @one_hour 3600
  @mm_per_reading 0.2794

  @spec start_link(GenServer.name(), (() -> DateTime.t())) :: GenServer.on_start()
  def start_link(name \\ __MODULE__, clock \\ &DateTime.utc_now/0) do
    GenServer.start_link(__MODULE__, [clock: clock], name: name)
  end

  @impl GenServer
  def init(opts) do
    {:ok, input} = GPIO.open(@pin, :input)
    :ok = GPIO.set_interrupts(input, :falling)
    {:ok, %{input: input, clock: opts[:clock], readings: []}}
  end

  @spec reset(GenServer.name()) :: :ok
  def reset(rain_gauge) do
    GenServer.cast(rain_gauge, :reset)
  end

  @spec hourly_rainfall(GenServer.name()) :: float()
  def hourly_rainfall(rain_gauge) do
    GenServer.call(rain_gauge, :hourly_rainfall)
  end

  @impl GenServer
  def handle_cast(:reset, state) do
    {:noreply, %{state | readings: []}}
  end

  @impl GenServer
  def handle_call(:hourly_rainfall, _from, state) do
    {:reply, calculate_hourly_rainfall(state.readings, state.clock.()), state}
  end

  defp calculate_hourly_rainfall(readings, now) do
    readings
    |> Enum.take_while(&(DateTime.diff(now, &1) < @one_hour))
    |> Enum.count()
    |> then(&(&1 * @mm_per_reading))
  end

  @impl GenServer
  def handle_info({:circuits_gpio, @pin, _timestamp, 0}, state) do
    reading = state.clock.()
    readings = Enum.take_while(state.readings, &(DateTime.diff(reading, &1) < @seconds_to_keep))
    {:noreply, %{state | readings: [reading | readings]}}
  end

  def handle_info(_message, state), do: {:noreply, state}
end
