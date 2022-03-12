defmodule WeatherFirmware.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias WeatherFirmware.Sensors.Anemometer
  alias WeatherFirmware.Sensors.Environment

  @impl Application
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherFirmware.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: WeatherFirmware.Worker.start_link(arg)
        # {WeatherFirmware.Worker, arg},
        Anemometer,
        Environment
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  defp children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: WeatherFirmware.Worker.start_link(arg)
      # {WeatherFirmware.Worker, arg},
    ]
  end

  defp children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: WeatherFirmware.Worker.start_link(arg)
    ]
  end

  defp target do
    Application.get_env(:weather_firmware, :target)
  end
end
