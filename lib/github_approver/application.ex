defmodule GithubApprover.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {port, _} = Integer.parse(System.get_env("PORT") || "4000")

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, GithubApprover.Router, [], [port: port])
    ]

    opts = [strategy: :one_for_one, name: GithubApprover.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
