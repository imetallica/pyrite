defmodule Commons.Mixfile do
  use Mix.Project

  def project do
    [app: :commons,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {Commons, []},
     applications: needed_apps()]
  end

  defp needed_apps() do
    apps = [:logger,
            :crypto,
            # Uncomment the database you want to use
            #:postgrex,
            #:mariaex,
            :ecto]

    case Mix.env do
      :dev -> [:sqlite_ecto] ++ apps
      _ -> apps
    end
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ecto, "~> 1.1"},

     # Uncomment these based on what database you desire to use.
     #{:postgrex, "~> 0.11"},  # PostgreSQL
     #{:mariaex,  "~> 0.7"},   # MySQL/MariaDB


     # These are only required on development. No need to import them.
     {:sqlite_ecto, "~> 1.1", only: :dev}]
  end
end
