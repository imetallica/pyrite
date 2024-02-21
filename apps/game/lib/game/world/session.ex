defmodule Game.World.Session do
  @moduledoc """
  Player session in the world.
  """
  alias Data.AccountHandler
  alias Data.Schemas.Account
  require Logger

  use GenServer

  defstruct [:socket_acceptor_pid, :username, :account]

  @type t() :: %__MODULE__{
          socket_acceptor_pid: pid(),
          username: binary(),
          account: Account.t()
        }

  @spec get_session(any()) :: nil | t()
  def get_session(username) do
    case Registry.lookup(__MODULE__, username) do
      [] -> nil
      [{pid, _}] -> GenServer.call(pid, :get_session)
    end
  end

  @spec create_session(pid(), binary()) :: :ok
  def create_session(socket_acceptor_pid, username)
      when is_pid(socket_acceptor_pid) and is_binary(username) do
    {:ok, _} =
      DynamicSupervisor.start_child(
        {:via, PartitionSupervisor, {Game.World.Session.Supervisor, username}},
        %{
          id: __MODULE__,
          start:
            {__MODULE__, :start_link,
             [%{username: username, socket_acceptor_pid: socket_acceptor_pid}]},
          restart: :temporary
        }
      )

    :ok
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: {:via, Registry, {__MODULE__, args.username}})
  end

  # Internal API handlers.

  def init(%{username: username, socket_acceptor_pid: socket_acceptor_pid}) do
    Logger.debug("Creating a new session for the player.")

    Process.flag(:trap_exit, true)
    Process.link(socket_acceptor_pid)

    {:ok, %__MODULE__{username: username, socket_acceptor_pid: socket_acceptor_pid},
     {:continue, :populate_session}}
  end

  def handle_continue(:populate_session, state = %__MODULE__{}) do
    Logger.debug("Populating session for the player #{state.username}.")

    {:noreply, %__MODULE__{state | account: AccountHandler.get_by_username(state.username)}}
  end

  def handle_call(:get_session, _from, state) do
    {:reply, state, state}
  end
end
