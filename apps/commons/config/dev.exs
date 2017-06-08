use Mix.Config

# Use this on development

# Database configuration
config :commons, Commons.Repo,
  adapter: EctoMnesia.Adapter,
  database: "data.sqlite3"

config :ecto_mnesia,
  host: {:system, :atom, "MNESIA_HOST", Kernel.node()},
  storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :disc_copies}

config :mnesia,
  dir: 'priv/data/mnesia' # Make sure this directory exists