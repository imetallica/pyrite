defmodule Game.Proto.Packet do
  @moduledoc """
  This module contains the handlers for the packets that
  are sent and received by the game server.
  """
  alias Game.Proto.Opcodes
  alias Game.Proto.Packet.CmsgAuthSession
  alias Game.Proto.Packet.CmsgCharEnum
  alias Game.Proto.Packet.CmsgPing
  alias Game.Socket.Acceptor

  @cmsg_auth_session Opcodes.cmsg_auth_session()
  @cmsg_char_enum Opcodes.cmsg_char_enum()
  @cmsg_ping Opcodes.cmsg_ping()

  def handle(
        <<_::unsigned-big-integer-size(16), @cmsg_auth_session::unsigned-little-integer-size(32),
          msg::binary>>,
        acceptor = %Acceptor{}
      ) do
    CmsgAuthSession.handle_packet(msg, acceptor)
  end

  def handle(
        <<_::unsigned-big-integer-size(16), @cmsg_ping::unsigned-little-integer-size(32),
          msg::binary>>,
        state = %Acceptor{}
      ) do
    CmsgPing.handle_packet(msg, state)
  end

  def handle(
        <<_::unsigned-big-integer-size(16), @cmsg_char_enum::unsigned-little-integer-size(32)>>,
        state = %Acceptor{}
      ) do
    CmsgCharEnum.handle_packet(nil, state)
  end
end
