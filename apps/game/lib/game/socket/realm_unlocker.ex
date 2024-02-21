defmodule Game.Socket.RealmUnlocker do
  @moduledoc """
  This module is responsible for unlocking the assigned realm.
  """
  alias Data.RealmHandler
  use GenServer

  def start_link(realm) do
    GenServer.start_link(__MODULE__, realm)
  end

  def init(init_arg) do
    {:ok, init_arg, {:continue, :unlock}}
  end

  def handle_continue(:unlock, state) do
    RealmHandler.realmlist()
    |> List.first()
    |> RealmHandler.up()

    {:noreply, state}
  end
end
