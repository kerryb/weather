defmodule WeatherUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WeatherUiWeb.Telemetry,
      # Don't start the PubSub system, as it's already started in
      # weather_firmware. Not sure how to handle this if we need it running
      # when only starting WeatherUi in isolation.
      # {Phoenix.PubSub, name: WeatherUi.PubSub},
      # Start the Endpoint (http/https)
      WeatherUiWeb.Endpoint
      # Start a worker by calling: WeatherUi.Worker.start_link(arg)
      # {WeatherUi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    WeatherUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
