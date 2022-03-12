defmodule WeatherFirmware.Sensors.Environment do
  @moduledoc """
  Interface to the BME280 environment sensor (temperature, humidity and
  pressure).

  The sensor is polled once a minute, and will return the latest stored values
  when queried.
  """

  use GenServer, start: {__MODULE__, :start_link, []}

  alias Bme280.Measurement

  @refresh_interval :timer.minutes(1)

  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl true
  def init(_opts) do
    {:ok, bme_280} = Bme280.start_link()
    Process.send_after(self(), :update, @refresh_interval)
    {:ok, %{bme_280: bme_280, measurement: Bme280.measure(bme_280)}}
  end

  @doc """
  Returns the latest humidity reading, as a percentage.
  """
  def humidity(name \\ __MODULE__) do
    GenServer.call(name, :humidity)
  end

  @doc """
  Returns the latest pressure reading, in hPa.
  """
  def pressure(name \\ __MODULE__) do
    GenServer.call(name, :pressure)
  end

  @doc """
  Returns the latest temperature reading, in °C.
  """
  def temperature(name \\ __MODULE__) do
    GenServer.call(name, :temperature)
  end

  @impl true
  def handle_call(:humidity, _from, state) do
    {:reply, state.measurement.humidity, state}
  end

  def handle_call(:pressure, _from, state) do
    {:reply, state.measurement.pressure, state}
  end

  def handle_call(:temperature, _from, state) do
    {:reply, state.measurement.temperature, state}
  end

  @impl true
  def handle_info(:update, state) do
    Bme280.measure_async(state.bme_280, self())
    Process.send_after(self(), :update, @refresh_interval)
    {:noreply, state}
  end

  def handle_info(%Measurement{} = measurement, state) do
    {:noreply, %{state | measurement: measurement}}
  end
end
