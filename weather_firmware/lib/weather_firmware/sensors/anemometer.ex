defmodule WeatherFirmware.Sensors.Anemometer do
  @moduledoc """
  Interface to the anemometer (wind speed sensor).

  The sensor produces two pulses per revolution, and a frequency of 3 pulses
  per second indicates a wind speed of 2m/s.
  """

  use GenServer, start: {__MODULE__, :start_link, []}
  alias Circuits.GPIO

  @pin Application.compile_env!(:weather_firmware, :pins).anemometer
  @pulses_to_average 10

  @spec start_link(GenServer.name()) :: GenServer.on_start()
  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, input} = GPIO.open(@pin, :input)
    :ok = GPIO.set_interrupts(input, :falling)
    #  measuring gaps, so we need n + 1 values to average over n
    buffer = RingBuffer.new(@pulses_to_average + 1)
    Process.send_after(self(), :broadcast_speed, 100)
    {:ok, %{input: input, buffer: buffer}}
  end

  @doc """
  Returns the latest wind speed reading, in m/s.
  """
  @spec speed(GenServer.name()) :: float()
  def speed(name \\ __MODULE__) do
    GenServer.call(name, :speed)
  end

  @impl GenServer
  def handle_call(:speed, _sender, state) do
    {:reply, calculate_speed(state.buffer), state}
  end

  @impl GenServer
  def handle_info({:circuits_gpio, @pin, timestamp, 0}, state) do
    {:noreply, %{state | buffer: RingBuffer.put(state.buffer, timestamp)}}
  end

  def handle_info(:broadcast_speed, state) do
    Process.send_after(self(), :broadcast_speed, 100)

    Phoenix.PubSub.broadcast!(
      WeatherUi.PubSub,
      "sensors",
      {:wind_speed, calculate_speed(state.buffer), :metres_per_second}
    )

    {:noreply, state}
  end

  def handle_info(_message, state), do: {:noreply, state}

  @nanoseconds_per_second 1_000_000_000
  @hz_to_metres_per_second 2 / 3

  # return zero until we have a full buffer
  defp calculate_speed(%{evicted: nil}), do: 0

  defp calculate_speed(buffer) do
    @hz_to_metres_per_second /
      ((RingBuffer.newest(buffer) - RingBuffer.oldest(buffer)) / @pulses_to_average /
         @nanoseconds_per_second)
  end
end
