defmodule WeatherFirmware.MixProject do
  use Mix.Project

  @app :weather_firmware
  @version "0.1.0"
  @all_targets [:rpi0]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {WeatherFirmware.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:circuits_gpio, "~> 1.0"},
      {:circuits_spi, "~> 1.3"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:nerves, "~> 1.7", runtime: false},
      {:phoenix_pubsub, "~> 2.0"},
      {:ring_logger, "~> 0.8"},
      {:shoehorn, "~> 0.8"},
      {:toolshed, "~> 0.2"},

      # Poncho dependencies
      {:weather_ui, path: "../weather_ui", targets: @all_targets, env: Mix.env()},

      # Dependencies for all targets except :host
      {:elixir_bme680, "~> 0.2", targets: @all_targets},
      {:nerves_pack, "~> 0.6", targets: @all_targets},
      {:nerves_runtime, "~> 0.11", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi0, "~> 1.18", runtime: false, targets: :rpi0}
    ]
  end

  def release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end
end
