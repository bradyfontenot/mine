# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mine,
  ecto_repos: [Mine.Repo]

# Configures the endpoint
config :mine, MineWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JIKKbeVd+IpDW8WDArM3JZ77QVujnb+QE3qHbfigOG8XBlly7Bzz18m3KlbXiNtX",
  render_errors: [view: MineWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Mine.Pubsub,
  live_view: [signing_salt: "8q5G7dvl"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use Hackney as default adapter for Tesla
config :tesla, adapter: Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
