# Allow capture_log to work on info and higher
config :logger, level: :info
# Print errors and warnings  during test and disable colors to more easily capture logs in tests
config :logger, :console,
  level: :warning,
  colors: [enabled: true]
