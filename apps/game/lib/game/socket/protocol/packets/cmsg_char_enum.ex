defmodule Game.Socket.Protocol.Packets.CmsgCharEnum do
  @moduledoc """
  CMSG_CHAR_ENUM is a World Packet that requests a SMSG_CHAR_ENUM
  from the server. It is sent by the client after receiving a
  successful SMSG_AUTH_RESPONSE.
  """
  alias Game.Socket.Acceptor

  require Logger

  @behaviour Game.Socket.Protocol.ClientPacket

  def handle_packet(_, acceptor = %Acceptor{}) do
    Logger.debug("Handling CMSG_CHAR_ENUM")
  end
end
