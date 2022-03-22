# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :curious_messenger,
  ecto_repos: [CuriousMessenger.Repo]

# Configures the endpoint
config :curious_messenger, CuriousMessengerWeb.Endpoint,
  url: [host: "localhost"],
  http: [
    port: System.get_env("PORT") || "80",
    protocol_options: [max_header_value_length: 8192]
  ],
  secret_key_base: "ms5e+3x2PlTjGkUlzBxvBNUwEp2A8rqAm+Xhll5seLBjRVvRlKxXvSFj08Djpg1j",
  render_errors: [view: CuriousMessengerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CuriousMessenger.PubSub,
  live_view: [signing_salt: "9DWrJ8GGi8FtjovL7F1LvAjwgrK7Qd0J"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :curious_messenger, :pow,
  user: CuriousMessenger.Auth.User,
  repo: CuriousMessenger.Repo,
  web_module: CuriousMessengerWeb

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
