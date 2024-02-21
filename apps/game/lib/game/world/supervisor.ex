defmodule Game.World.Supervisor do
  @moduledoc """
  The supervisor for the world processes.
  """
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      Game.World.Timer,
      {Registry, keys: :unique, name: Game.World.Session, partitions: System.schedulers_online()},
      {PartitionSupervisor, child_spec: DynamicSupervisor, name: Game.World.Session.Supervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
