defmodule Realmd.Socket.Supervisor do
  @moduledoc """
  This module is responsible for managing the socket connections to the realmd server.
  """
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      {PartitionSupervisor, child_spec: Realmd.Socket.Listener, name: Realmd.Socket.Listener},
      {PartitionSupervisor, child_spec: DynamicSupervisor, name: Realmd.Socket.Acceptor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
