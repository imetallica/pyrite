defmodule Game.Socket.Protocol.Packets.CmsgPing do
  @moduledoc """
  CMSG_PING is a World Packet sent every 30 seconds. It is followed by a SMSG_PONG from the server.
  """
  alias Game.Socket.Acceptor

  require Logger

  defstruct [:sequence_id, :latency]

  @behaviour Game.Socket.Protocol.ClientPacket

  def handle_packet(
        packet,
        acceptor = %Acceptor{}
      ) do
    with {:ok, parsed = %__MODULE__{}} <- parse(packet) do
    end
  end

  def parse(
        <<sequence_id::unsigned-little-integer-size(32),
          latency::unsigned-little-integer-size(32)>>
      ) do
    Logger.debug("Handling PING with latency: #{latency} milliseconds.")

    {:ok, %__MODULE__{sequence_id: sequence_id, latency: latency}}
  end
end
