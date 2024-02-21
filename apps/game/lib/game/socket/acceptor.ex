defmodule Game.Socket.Acceptor do
  @moduledoc """
  The acceptor is a process who handles the interaction with the client.
  """
  alias Game.Socket.Protocol.AuthPackets
  alias Game.Socket.Protocol.Packets.SmsgAuthChallenge
  alias Game.Socket.Protocol.Packets.SmsgAuthResponse
  alias Shared.BinaryPacket
  alias Shared.BinaryPacketWithEncryptedHeaders

  use GenServer

  require Logger

  defstruct [
    :socket,
    :encryption_salt,
    :encryption_proof,
    current_step: :authentication
  ]

  @type t() :: %__MODULE__{
          socket: :inet.socket(),
          current_step: :authentication | :character_creation | :login | :in_game
        }

  def initialize_acceptor(socket) do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {__MODULE__, self()}},
      %{
        id: __MODULE__,
        start: {__MODULE__, :start_link, [socket]},
        restart: :temporary
      }
    )
  end

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    Process.flag(:trap_exit, true)
    Logger.debug("Handling socket connection.")

    {:ok, %__MODULE__{socket: socket}, {:continue, :send_smsg_auth_callenge}}
  end

  def handle_continue(:send_smsg_auth_callenge, state = %__MODULE__{}) do
    Logger.debug("Sending smsg_auth_challenge.")
    :inet.setopts(state.socket, active: :once)
    :ok = :gen_tcp.send(state.socket, BinaryPacket.to_binary(SmsgAuthChallenge.new()))

    {:noreply, state}
  end

  def handle_info({:tcp, socket, msg}, state = %__MODULE__{current_step: :authentication}) do
    Logger.debug("[Authentication] Received packet: #{inspect(msg)}.")
    :inet.setopts(socket, active: :once)

    case AuthPackets.handle_packet(msg, state) do
      {:error, response = %SmsgAuthResponse{}, updated_state = %__MODULE__{}} ->
        Logger.debug("Handled packet: #{inspect(response)}.")

        :ok =
          :gen_tcp.send(
            socket,
            BinaryPacketWithEncryptedHeaders.to_binary(
              response,
              updated_state.encryption_salt
            )
          )

        {:stop, response, updated_state}

      {:ok, response = %SmsgAuthResponse{}, updated_state = %__MODULE__{}} ->
        Logger.debug("Handling packet: #{inspect(response)}.")
        # TODO: Add code to handle the packet.
        :ok =
          :gen_tcp.send(
            socket,
            BinaryPacketWithEncryptedHeaders.to_binary(
              response,
              updated_state.encryption_salt
            )
          )

        {:noreply, updated_state}
    end
  end

  def handle_info({:tcp_closed, _}, state) do
    Logger.debug("Connection closed.")
    {:stop, :normal, state}
  end
end
