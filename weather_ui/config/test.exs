import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :weather_ui, WeatherUiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mMaOXmBZgfaVPw6q7RdtkiS3AuYSiNwLQMc+FwCD7WAKSRUL1eA1foEdbL/3OCup",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
