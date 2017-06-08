use Mix.Config

config :realm,
  realmlist: [%{name: "Stellaris", host: "127.0.0.1", port: 8080}]




# To avoid Ecto spamming
config :realm, ecto_repos: []

import_config "#{Mix.env}.exs"