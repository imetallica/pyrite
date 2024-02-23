defmodule Game.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias Shared.Data.RealmHandler
  require Logger
  use Application

  @impl true
  def start(_type, _args) do
    Logger.info("""
    Initializing Game server.
    """)

    children = [
      Game.World.Supervisor,

      # This should be last.
      Game.Socket.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Game.Supervisor]

    Supervisor.start_link(children, opts)
  end

  @impl true
  def stop(_) do
    RealmHandler.realmlist()
    |> List.first()
    |> then(fn realm ->
      RealmHandler.down(realm)
    end)

    :ok
  end
end
