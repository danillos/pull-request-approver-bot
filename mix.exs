defmodule GithubApprover.Mixfile do
  use Mix.Project

  def project do
    [app: :github_approver,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {GithubApprover.Application, []}]
  end

  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:plug_cowboy, "~> 1.0"},
      {:plug, "~> 1.8"},
      {:poison, "~> 3.0"},
      {:mock, "~> 0.2", only: :test},
      {:tesla, "~> 0.10"},
      {:hackney, "~> 1.15"},
      {:timex, "~> 3.6"},
    ]
  end
end
