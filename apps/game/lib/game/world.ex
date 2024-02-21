defmodule Game.World do
  @moduledoc """
  Interface for the world process and their operations.
  """
  alias Game.World.Session
  alias Game.World.Timer

  @doc """
  Returns the current world tick.
  """
  @spec current_tick() :: integer
  def current_tick do
    case :ets.lookup(Timer, :current_tick) do
      [current_tick: tick] -> tick
    end
  end

  @doc """
  Creates a new world session and links with the given process pid..
  """
  @spec create_session(socket_acceptor_pid :: pid(), username :: binary()) :: :ok
  defdelegate create_session(socket_acceptor_pid, username), to: Session

  @doc """
  Returns the session for the given username.
  """
  @spec get_session(username :: binary()) :: Session.t() | nil
  defdelegate get_session(username), to: Session
end
