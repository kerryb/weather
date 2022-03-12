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
  end

  def start_link do
    Agent.start_link(fn ->
      %Measurement{humidity: 78.90, pressure: 45.67, temperature: 12.34}
    end)
  end

  def measure(pid) do
    Agent.get(pid, & &1)
  end

  def measure_async(pid, send_to) do
    Agent.cast(pid, fn state ->
      send(send_to, state)
      state
    end)
  end
end
