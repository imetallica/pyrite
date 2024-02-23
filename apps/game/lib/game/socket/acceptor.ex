defmodule Game.Socket.Acceptor do
  @moduledoc """
  The acceptor is a process who handles the interaction with the client.
  """
  alias Game.Socket.Protocol.AuthPackets
  alias Game.Socket.Protocol.Packets.SmsgAuthChallenge
  alias Game.Socket.Protocol.Packets.SmsgAuthResponse
  alias Game.Socket.Protocol.Packets.SmsgPong
  alias Game.World.Session
  alias Shared.BinaryData
  alias Shared.BinaryPacket
  alias Shared.BinaryPacketWithEncryptedHeaders
  alias Shared.Crypto

  use GenServer

  require Logger

  defstruct [
    :socket,
    :seed,
    :session,
    :session_key,
    :client_seed,
    :client_proof,
    :address,
    :last_ping_time,
    :latency,
    current_step: :waiting_session_packet
  ]

  @type t() :: %__MODULE__{
          socket: :inet.socket(),
          seed: non_neg_integer(),
          session: nil | Session.t(),
          session_key: nil | binary(),
          client_seed: non_neg_integer(),
          client_proof: nil | binary(),
          address: :inet.hostname(),
          last_ping_time: nil | integer(),
          latency: nil | non_neg_integer(),
          current_step:
            :waiting_session_packet | :authenticated | :character_creation | :login | :in_game
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
    Logger.debug("Handling socket connection.")

    Process.flag(:trap_exit, true)

    {:ok, %__MODULE__{socket: socket}, {:continue, :send_smsg_auth_challenge}}
  end

  def handle_continue(:send_smsg_auth_challenge, state = %__MODULE__{}) do
    Logger.debug("[SMSG_AUTH_CHALLENGE] Sending packet.")

    with :ok <- :inet.setopts(state.socket, active: :once),
         {:ok, address} <- :inet.gethostname(state.socket) do
      auth_challenge = SmsgAuthChallenge.new()

      :ok =
        :gen_tcp.send(
          state.socket,
          BinaryPacket.to_binary(auth_challenge)
        )

      {:noreply, %__MODULE__{state | address: to_string(address), seed: auth_challenge.challenge}}
    end
  end

  def handle_info({:tcp, socket, msg}, state = %__MODULE__{current_step: :waiting_session_packet}) do
    Logger.debug("[WAITING SESSION PACKET] Received packet: #{inspect(msg)}.")

    :inet.setopts(socket, active: :once)

    case AuthPackets.handle_packet(msg, state) do
      {:error, response = %SmsgAuthResponse{}, updated_state = %__MODULE__{}} ->
        Logger.debug("[SENDING PACKET] #{inspect(response)} | state: #{inspect(updated_state)}.")

        :ok =
          :gen_tcp.send(
            socket,
            BinaryPacketWithEncryptedHeaders.to_binary(response, updated_state.session_key)
          )

        {:stop, response, updated_state}

      {:ok, response = %SmsgAuthResponse{}, updated_state = %__MODULE__{}} ->
        Logger.debug("[SENDING PACKET] #{inspect(response)} | state: #{inspect(updated_state)}.")

        :ok =
          :gen_tcp.send(
            socket,
            BinaryPacketWithEncryptedHeaders.to_binary(response, updated_state.session_key)
          )

        {:noreply, %__MODULE__{updated_state | current_step: :authenticated}}
    end
  end

  # Here, the packets are already encrypted, so we need to decrypt.
  def handle_info({:tcp, socket, msg}, state = %__MODULE__{current_step: :authenticated}) do
    Logger.debug("[AUTHENTICATED] Received packet: #{inspect(msg)}.")
    :inet.setopts(socket, active: :once)

    msg =
      Crypto.decrypt(
        msg,
        BinaryData.to_little_endian(state.session_key, byte_size(state.session_key) * 8)
      )

    case AuthPackets.handle_packet(msg, state) do
      {:error, response = %SmsgAuthResponse{}, updated_state = %__MODULE__{}} ->
        Logger.debug("Handled packet: #{inspect(response)} | state: #{inspect(updated_state)}.")

        :ok =
          :gen_tcp.send(
            socket,
            BinaryPacketWithEncryptedHeaders.to_binary(
              response,
              updated_state.session_key
            )
          )

        {:noreply, updated_state}

      {:ok, response = %SmsgPong{}, updated_state = %__MODULE__{}} ->
        Logger.debug("[SENDING PACKET] #{inspect(response)} | state: #{inspect(updated_state)}.")

        :ok =
          :gen_tcp.send(
            socket,
            BinaryPacketWithEncryptedHeaders.to_binary(
              response,
              updated_state.session_key
            )
          )

        {:noreply, updated_state}

      {:ok, response = %SmsgAuthResponse{}, updated_state = %__MODULE__{}} ->
        Logger.debug("Handling packet: #{inspect(response)} | state: #{inspect(updated_state)}.")
        # TODO: Add code to handle the packet.
        :ok =
          :gen_tcp.send(
            socket,
            BinaryPacketWithEncryptedHeaders.to_binary(
              response,
              updated_state.session_key
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
