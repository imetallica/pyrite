defmodule Game.Socket.Acceptor do
  @moduledoc """
  The acceptor is a process who handles the interaction with the client.
  """
  alias Game.Proto.Packet.SmsgAuthChallenge
  alias Game.Proto.Packet
  alias Shared.BinaryData
  alias Shared.Crypto
  alias Shared.Crypto.Keystate
  alias Shared.Data.Schemas.Account

  use GenServer

  require Logger

  defstruct [
    :account,
    :socket,
    :seed,
    :client_seed,
    :client_proof,
    :address,
    :last_ping_time,
    :latency,
    encrypted?: false,
    key_state_encrypt: Keystate.new(),
    key_state_decrypt: Keystate.new()
  ]

  @type t() :: %__MODULE__{
          account: Account.t(),
          socket: :inet.socket(),
          seed: non_neg_integer(),
          client_seed: non_neg_integer(),
          client_proof: nil | binary(),
          address: :inet.hostname(),
          last_ping_time: nil | integer(),
          latency: nil | non_neg_integer(),
          encrypted?: boolean(),
          key_state_encrypt: non_neg_integer(),
          key_state_decrypt: non_neg_integer()
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

    {:ok, socket, {:continue, :send_smsg_auth_challenge}}
  end

  def handle_continue(:send_smsg_auth_challenge, socket) do
    start = System.system_time(:millisecond)

    with :ok <-
           :telemetry.execute(
             [:game, :acceptor, :begin],
             %{
               start: start
             },
             %{socket: socket}
           ),
         :ok <- :inet.setopts(socket, active: :once),
         {:ok, address} <- :inet.gethostname(socket),
         auth_challenge = SmsgAuthChallenge.new(),
         :ok = :gen_tcp.send(socket, SmsgAuthChallenge.to_binary(auth_challenge)),
         :ok <-
           :telemetry.execute(
             [:game, :acceptor, :send],
             %{
               latency: System.system_time(:millisecond) - start
             },
             %{socket: socket}
           ) do
      Logger.debug("[SMSG_AUTH_CHALLENGE] Sending packet to: #{inspect(address)}.")

      {:noreply,
       %__MODULE__{address: to_string(address), seed: auth_challenge.challenge, socket: socket}}
    end
  end

  def handle_info({:tcp, socket, msg}, state = %__MODULE__{encrypted?: false}) do
    start = System.system_time(:millisecond)
    Logger.debug("[UNENCRYPTED] Received packet: #{inspect(msg)} with size #{byte_size(msg)}.")

    # TODO: Handle encrypted packets.
    with :ok <-
           :telemetry.execute(
             [:game, :acceptor, :begin],
             %{
               start: start
             },
             %{socket: state.socket}
           ),
         :ok <- :inet.setopts(socket, active: :once),
         {:ok, data, acceptor} <- handle_packet(msg, socket, state),
         :ok <- :gen_tcp.send(socket, data),
         :ok <-
           :telemetry.execute(
             [:game, :acceptor, :send],
             %{
               latency: System.system_time(:millisecond) - start
             },
             %{socket: state.socket}
           ) do
      Logger.debug("Sent packet: #{inspect(data)}.")
      {:noreply, acceptor}
    end
  end

  # Here, the packets are already encrypted, so we need to decrypt.
  def handle_info({:tcp, socket, msg}, state = %__MODULE__{encrypted?: true}) do
    start = System.system_time(:millisecond)
    Logger.debug("[ENCRYPTED] Received packet: #{inspect(msg)} with size #{byte_size(msg)}.")

    with :ok <-
           :telemetry.execute(
             [:game, :acceptor, :begin],
             %{
               start: start
             },
             %{socket: state.socket}
           ),
         :ok <- :inet.setopts(socket, active: :once),
         {:ok, data, acceptor} <- handle_encrypted_packet(msg, socket, state),
         :ok <- :gen_tcp.send(socket, data),
         :ok <-
           :telemetry.execute(
             [:game, :acceptor, :send],
             %{
               latency: System.system_time(:millisecond) - start
             },
             %{socket: state.socket}
           ) do
      Logger.debug("Sent packet: #{inspect(data)}.")
      {:noreply, acceptor}
    end
  end

  def handle_info({:tcp_closed, _}, state) do
    Logger.debug("Connection closed.")
    {:stop, :normal, state}
  end

  defp handle_packet(msg, socket, state = %__MODULE__{}) do
    do_handle_packet(msg, socket, state)
  end

  defp handle_encrypted_packet(
         msg,
         socket,
         state = %__MODULE__{account: %Account{session_key: session_key}}
       ) do
    salt =
      BinaryData.to_little_endian(session_key, byte_size(session_key) * 8)

    {msg, key_state_decrypt} = Crypto.decrypt(msg, salt, state.key_state_decrypt)

    do_handle_packet(msg, socket, %__MODULE__{state | key_state_decrypt: key_state_decrypt})
  end

  defp do_handle_packet(msg, socket, state = %__MODULE__{}) do
    case Packet.handle(msg, state) do
      {:error, data} ->
        :ok = :gen_tcp.send(socket, data)
        {:stop, :normal, state}

      :ignore ->
        {:noreply, state}

      {:ok, data, state} ->
        {:ok, data, state}
    end
  end
end
