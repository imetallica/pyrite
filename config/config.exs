# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :shared,
  ecto_repos: [Shared.Data.Repo]

config :shared, Shared.Data.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "pyrite_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :logger, :console,
  level: :debug,
  format: "$date $time [$level] | $metadata| $message\n",
  metadata: [:module, :pid]

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#
