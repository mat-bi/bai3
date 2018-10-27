# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bai3,
  ecto_repos: [Bai3.Repo]

# Configures the endpoint
config :bai3, Bai3Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "h3XdG7lw48MZNvTzi3UjLTErsJ3O0gD2KDbM/GKn0snVDqUjcZvCJeOcZ1EYF9K5",
  render_errors: [view: Bai3Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bai3.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
