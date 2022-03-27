defmodule WeatherFirmware.Sensors.WindVane do
  @moduledoc """
  Interface to the wind vane.

  Input is a value between 0 and 1, from a voltage divider using a 4k7 resistor
  and a 3.3V reference voltage, converted via an ADC.

  Values correspond to wind direction as follows:

  | Direction | Volue |
  |-----------|-------|
  | 0	        | 0.875 |
  | 22.5	    | 0.582 |
  | 45	      | 0.635 |
  | 67.5	    | 0.159 |
  | 90	      | 0.175 |
  | 112.5	    | 0.127 |
  | 135	      | 0.318 |
  | 157.5	    | 0.230 |
  | 180	      | 0.453 |
  | 202.5	    | 0.400 |
  | 225	      | 0.772 |
  | 247.5	    | 0.750 |
  | 270	      | 0.962 |
  | 292.5	    | 0.899 |
  | 315	      | 0.932 |
  | 337.5	    | 0.823 |
  """

  use GenServer, start: {__MODULE__, :start_link, []}

  alias Circuits.SPI

  @spec start_link(GenServer.name()) :: GenServer.on_start()
  def start_link(name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, adc} = SPI.open("spidev0.0")
    {:ok, %{adc: adc}}
  end

  @doc """
  Return the wind direction in degrees.

  Accepts an optional function for testing, to override the fetching of the
  level from the ADC.
  """
  @spec direction(pid(), (pid() -> integer())) :: float()
  def direction(pid, fun \\ &read_level/1), do: pid |> fun.() |> do_direction()

  defp do_direction(level) when level < 145, do: 112.5
  defp do_direction(level) when level < 170, do: 67.5
  defp do_direction(level) when level < 205, do: 90.0
  defp do_direction(level) when level < 276, do: 157.5
  defp do_direction(level) when level < 364, do: 135.0
  defp do_direction(level) when level < 435, do: 202.5
  defp do_direction(level) when level < 525, do: 180.0
  defp do_direction(level) when level < 621, do: 22.5
  defp do_direction(level) when level < 705, do: 45.0
  defp do_direction(level) when level < 778, do: 247.5
  defp do_direction(level) when level < 815, do: 225.0
  defp do_direction(level) when level < 868, do: 337.5
  defp do_direction(level) when level < 907, do: 0.0
  defp do_direction(level) when level < 936, do: 292.5
  defp do_direction(level) when level < 968, do: 315.0
  defp do_direction(_level), do: 270

  defp read_level(pid) do
    GenServer.call(pid, :read_level)
  end

  @impl GenServer
  def handle_call(:read_level, _from, state) do
    {:ok, <<_::size(6), level::size(10)>>} = SPI.transfer(state.adc, <<0x78, 0x00>>)
    {:reply, level, state}
  end
end
