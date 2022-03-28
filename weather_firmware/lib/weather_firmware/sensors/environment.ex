defmodule WeatherFirmware.Sensors.Environment do
  @moduledoc """
  Interface to the BME280 environment sensor (temperature, humidity and
  pressure).

  The sensor is polled every ten seconds, and will return the latest stored
  values when queried.
  """

  use GenServer, start: {__MODULE__, :start_link, []}

  alias Bme280.Measurement

  @refresh_interval :timer.seconds(10)

  @spec start_link(GenServer.name()) :: GenServer.on_start()
  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, bme_280} = Bme280.start_link()
    Process.send_after(self(), :update, @refresh_interval)
    {:ok, %{bme_280: bme_280, measurement: Bme280.measure(bme_280)}}
  end

  @doc """
  Returns the latest humidity reading, as a percentage.
  """
  @spec humidity(GenServer.name()) :: float()
  def humidity(name \\ __MODULE__) do
    GenServer.call(name, :humidity)
  end

  @doc """
  Returns the latest pressure reading, in hPa.
  """
  @spec pressure(GenServer.name()) :: float()
  def pressure(name \\ __MODULE__) do
    GenServer.call(name, :pressure)
  end

  @doc """
  Returns the latest temperature reading, in °C.
  """
  @spec temperature(GenServer.name()) :: float()
  def temperature(name \\ __MODULE__) do
    GenServer.call(name, :temperature)
  end

  @impl GenServer
  def handle_call(:humidity, _from, state) do
    {:reply, state.measurement.humidity, state}
  end

  def handle_call(:pressure, _from, state) do
    {:reply, state.measurement.pressure, state}
  end

  def handle_call(:temperature, _from, state) do
    {:reply, state.measurement.temperature, state}
  end

  @impl GenServer
  def handle_info(:update, state) do
    Bme280.measure_async(state.bme_280, self())
    Process.send_after(self(), :update, @refresh_interval)
    {:noreply, state}
  end

  def handle_info(%Measurement{} = measurement, state) do
    {:noreply, %{state | measurement: measurement}}
  end
end
