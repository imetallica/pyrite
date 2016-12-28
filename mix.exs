defmodule Pyrite.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/imetallica/pyrite",
     #homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
     docs: [extras: ["README.md", "LICENSE"]],
     deps: deps]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder

  defp deps do
    [{:credo, "~> 0.5.3", only: [:dev, :test]},
     {:earmark, "~> 1.0", only: :dev},
     {:ex_doc, "~> 0.14.5", only: :dev},
     {:exsync, "~> 0.1", only: :dev}]
  end
end
