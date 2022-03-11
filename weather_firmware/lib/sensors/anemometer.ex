defmodule WeatherFirmware.Sensors.Anemometer do
  @moduledoc """
  Interface to the Anemometer (wind speed sensor).

  The sensor produces two pulses per revolution, and a frequency of 3 pulses
  per second indicates a wind speed of 2m/s.
  """

  use GenServer, start: {__MODULE__, :start_link, []}
  alias Circuits.GPIO

  @pin Application.compile_env!(:weather_firmware, :pins).anemometer

  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl true
  def init(_opts) do
    {:ok, input} = GPIO.open(@pin, :input)
    :ok = GPIO.set_interrupts(input, :falling)
    {:ok, %{input: input, last_pulse: 0, speed: 0}}
  end

  @doc """
  Returns the latest windspeed reading, in m/s.
  """
  def speed(name \\ __MODULE__) do
    GenServer.call(name, :speed)
  end

  @impl true
  def handle_call(:speed, _sender, state) do
    {:reply, state.speed, state}
  end

  @impl true
  def handle_info({:circuits_gpio, @pin, timestamp, 0}, state) do
    {:noreply,
     %{state | last_pulse: timestamp, speed: calculate_speed(state.last_pulse, timestamp)}}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  @nanoseconds_per_second 1_000_000_000
  @hz_to_metres_per_second 2 / 3
  defp calculate_speed(timestamp_1, timestamp_2) do
    @hz_to_metres_per_second / ((timestamp_2 - timestamp_1) / @nanoseconds_per_second)
  end
end
