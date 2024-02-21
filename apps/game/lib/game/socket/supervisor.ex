defmodule Game.Socket.Supervisor do
  @moduledoc """
  This module is responsible for managing the socket connections to the realmd server.
  """
  alias Data.RealmHandler
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(_) do
    realm = List.first(RealmHandler.realmlist())

    children = [
      {PartitionSupervisor,
       child_spec: {Game.Socket.Listener, realm}, name: Game.Socket.Listener},
      {PartitionSupervisor, child_spec: DynamicSupervisor, name: Game.Socket.Acceptor},
      Game.Socket.RealmUnlocker
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
