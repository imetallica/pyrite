defmodule Game.Socket.Protocol.Packets.CmsgPing do
  @moduledoc """
  CMSG_PING is a World Packet sent every 30 seconds. It is followed by a SMSG_PONG from the server.
  """
  alias Game.Socket.Protocol.Packets.SmsgPong
  alias Game.Socket.Acceptor

  require Logger

  defstruct [:sequence_id, :latency]

  @behaviour Game.Socket.Protocol.ClientPacket

  def handle_packet(packet, acceptor = %Acceptor{}) when is_binary(packet) do
    with {:ok, parsed = %__MODULE__{}} <- parse(packet) do
      current_tick = Game.World.current_tick()

      last_ping_time =
        if is_nil(acceptor.last_ping_time) do
          current_tick
        else
          current_tick - acceptor.last_ping_time
        end

      {:ok, %SmsgPong{sequence_id: parsed.sequence_id},
       %Acceptor{acceptor | last_ping_time: last_ping_time, latency: parsed.latency}}
    end
  end

  defp parse(
         <<sequence_id::unsigned-little-integer-size(32),
           latency::unsigned-little-integer-size(32)>>
       ) do
    Logger.debug("Handling PING with latency: #{latency} milliseconds.")

    {:ok, %__MODULE__{sequence_id: sequence_id, latency: latency}}
  end
end
