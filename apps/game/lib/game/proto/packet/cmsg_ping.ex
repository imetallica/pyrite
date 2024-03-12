defmodule Game.Proto.Packet.CmsgPing do
  @moduledoc """
  CMSG_PING is a World Packet sent every 30 seconds. It is followed by a SMSG_PONG from the server.
  """
  alias Game.Proto.Packet.SmsgPong
  alias Game.Socket.Acceptor
  alias Shared.Data.Schemas.Account

  require Logger

  defstruct [:sequence_id, :latency]

  @behaviour Game.Proto.ClientPacket

  def handle_packet(packet, acceptor = %Acceptor{}) when is_binary(packet) do
    with {:ok, parsed = %__MODULE__{}} <- decode(packet),
         {:ok, pong = %SmsgPong{}, acceptor = %Acceptor{}} <- handle(parsed, acceptor) do
      encode(pong, acceptor)
    end
  end

  defp decode(
         <<sequence_id::unsigned-little-integer-size(32),
           latency::unsigned-little-integer-size(32)>>
       ) do
    Logger.debug("Handling PING with latency: #{latency} milliseconds.")

    {:ok, %__MODULE__{sequence_id: sequence_id, latency: latency}}
  end

  defp handle(
         %__MODULE__{sequence_id: sequence_id, latency: latency},
         acceptor = %Acceptor{last_ping_time: last_ping_time}
       ) do
    current_tick = Game.World.current_tick()

    [sequence_id: sequence_id]
    |> SmsgPong.new()
    |> then(fn pong ->
      if is_nil(acceptor.last_ping_time) do
        {:ok, pong, %Acceptor{acceptor | last_ping_time: current_tick, latency: latency}}
      else
        {:ok, pong,
         %Acceptor{acceptor | last_ping_time: current_tick - last_ping_time, latency: latency}}
      end
    end)
  end

  defp encode(
         pong = %SmsgPong{sequence_id: sequence_id},
         acceptor = %Acceptor{account: %Account{session_key: session_key}}
       ) do
    Logger.debug("Sending PONG with sequence_id: #{sequence_id}.")

    pong
    |> SmsgPong.to_binary(session_key, acceptor.key_state_encrypt)
    |> then(fn {data, key_state_encrypt} ->
      {:ok, data, %Acceptor{acceptor | key_state_encrypt: key_state_encrypt}}
    end)
  end
end
