defmodule Bme280 do
  @moduledoc """
  Dummy implementation of the main module from `elixir_bme680`, loaded in dev
  and test environments.
  """

  defmodule Measurement do
    @moduledoc """
    A copy of the data structure used by the real module.
    """

    defstruct [:humidity, :pressure, :temperature]
    @type t :: %__MODULE__{humidity: float(), pressure: float(), temperature: float()}
  end

  @spec start_link :: GenServer.on_start()
  def start_link do
    Agent.start_link(fn ->
      %Measurement{humidity: 78.90, pressure: 45.67, temperature: 12.34}
    end)
  end

  @spec measure(pid()) :: Measurement.t()
  def measure(pid) do
    Agent.get(pid, & &1)
  end

  @spec measure_async(pid(), pid()) :: :ok
  def measure_async(pid, send_to) do
    Agent.cast(pid, fn state ->
      send(send_to, state)
      state
    end)
  end
end
