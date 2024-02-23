defmodule Game.Socket.Protocol.AuthPackets do
  alias Game.Socket.Acceptor
  alias Game.Socket.Protocol.Opcodes
  alias Game.Socket.Protocol.Packets.CmsgAuthSession
  alias Game.Socket.Protocol.Packets.CmsgCharEnum
  alias Game.Socket.Protocol.Packets.CmsgPing

  @cmsg_auth_session Opcodes.cmsg_auth_session()
  @cmsg_char_enum Opcodes.cmsg_char_enum()
  @cmsg_ping Opcodes.cmsg_ping()

  def handle_packet(
        <<_::unsigned-big-integer-size(16), @cmsg_auth_session::unsigned-little-integer-size(32),
          msg::binary>>,
        state = %Acceptor{}
      ) do
    CmsgAuthSession.handle_packet(msg, state)
  end

  def handle_packet(
        <<_::unsigned-big-integer-size(16), @cmsg_ping::unsigned-little-integer-size(32),
          msg::binary>>,
        state = %Acceptor{}
      ) do
    CmsgPing.handle_packet(msg, state)
  end

  def handle_packet(
        <<_::unsigned-big-integer-size(16), @cmsg_char_enum::unsigned-little-integer-size(32)>>,
        state = %Acceptor{}
      ) do
    CmsgCharEnum.handle_packet(nil, state)
  end
end
