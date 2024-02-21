defmodule Realmd.Socket.Acceptor do
  @moduledoc """
  The acceptor is a process who handles the interaction with the client.
  """
  alias Data.Schemas.Account
  alias Realmd.Messages.Realmlist
  alias Realmd.Messages.LogonProof
  alias Realmd.Messages.LogonChallenge
  alias Realmd.Socket.Opcodes

  use GenServer

  require Logger

  defstruct [
    :socket,
    :build,
    :account,
    :public_server_key,
    :private_server_key,
    :salt,
    :verifier,
    :public_client_key,
    :m1,
    :session_key
  ]

  @type t() :: %__MODULE__{
          socket: :inet.socket(),
          account: Account.t(),
          public_server_key: binary(),
          private_server_key: binary(),
          salt: binary(),
          verifier: binary(),
          public_client_key: binary(),
          m1: binary(),
          session_key: binary()
        }

  def initialize_acceptor do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {__MODULE__, self()}},
      %{
        id: __MODULE__,
        start: {__MODULE__, :start_link, []},
        restart: :temporary
      }
    )
  end

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Logger.debug("Handling socket connection.")

    {:ok, %__MODULE__{}}
  end

  @logon_challenge Opcodes.logon_challenge()
  def handle_info({:tcp, socket, <<@logon_challenge::size(8), msg::binary>>}, state) do
    Logger.debug("Received logon challenge: #{inspect(msg)}.")
    :inet.setopts(socket, active: :once)

    with {:ok, msg} <- LogonChallenge.fetch_and_check_identity(msg),
         {:ok, msg = %LogonChallenge{}} <- LogonChallenge.fetch_account(msg) do
      :gen_tcp.send(socket, LogonChallenge.to_binary_message(msg))

      {:noreply,
       %__MODULE__{
         state
         | account: msg.account,
           build: msg.build,
           public_server_key: msg.public_server_key,
           private_server_key: msg.private_server_key,
           salt: msg.account && msg.account.salt,
           verifier: msg.account.verifier
       }}
    end
  end

  @logon_proof Opcodes.logon_proof()
  def handle_info({:tcp, socket, <<@logon_proof::size(8), msg::binary>>}, state) do
    Logger.debug("Received logon proof: #{inspect(msg)}.")
    :inet.setopts(socket, active: :once)

    with {:ok, msg} <- LogonProof.fetch_logon_proof(msg),
         {:ok, msg} <- LogonProof.fetch_server_key(msg, state),
         {:ok, msg = %LogonProof{}} <- LogonProof.check_password(msg, state) do
      :ok = :gen_tcp.send(socket, LogonProof.to_binary_message(msg))

      {:noreply,
       %__MODULE__{
         state
         | session_key: msg.session_key,
           public_client_key: msg.public_client_key
       }}
    end
  end

  @realmlist Opcodes.realmlist()
  def handle_info({:tcp, socket, <<@realmlist::size(8), _msg::binary>>}, state) do
    Logger.debug("Received realmlist request.")
    :inet.setopts(socket, active: :once)

    with {:ok, msg} <- Realmlist.fetch_realmlist(state) do
      :gen_tcp.send(socket, Realmlist.to_binary_message(msg))

      {:noreply, state}
    end
  end

  def handle_info({:tcp, socket, msg}, state) do
    Logger.debug("Received unknown message: #{inspect(msg)}. Stopping.")
    :inet.setopts(socket, active: :once)

    {:stop, :normal, state}
  end

  def handle_info({:tcp_closed, _}, state) do
    Logger.debug("Connection closed.")
    {:stop, :normal, state}
  end
end
