defmodule Pyrite.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        flags: [:error_handling, :extra_return, :missing_return, :underspecs, :unmatched_returns]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:credo, "> 0.0.0", runtime: false, only: [:dev, :test]},
      {:dialyxir, "> 0.0.0", runtime: false, only: [:dev, :test]}
    ]
  end
end
