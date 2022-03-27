defmodule WeatherFirmware.MixProject do
  use Mix.Project

  @app :weather_firmware
  @version "0.1.0"
  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4, :bbb, :osd32mp1, :x86_64]

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
      # NOTE: It's generally low risk and recommended to follow minor version
      # bumps to Nerves systems. Since these include Linux kernel and Erlang
      # version updates, please review their release notes in case
      # changes to your application are needed.
      {:nerves_system_bbb, "~> 2.13", runtime: false, targets: :bbb},
      {:nerves_system_osd32mp1, "~> 0.9", runtime: false, targets: :osd32mp1},
      {:nerves_system_rpi, "~> 1.18", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.18", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.18", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.18", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.18", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.18", runtime: false, targets: :rpi4},
      {:nerves_system_x86_64, "~> 1.18", runtime: false, targets: :x86_64}
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
