defmodule Game.Socket.Protocol.AuthPackets do
  alias Game.Socket.Acceptor
  alias Game.Socket.Protocol.Opcodes
  alias Game.Socket.Protocol.Packets.CmsgAuthSession

  @cmsg_auth_session Opcodes.cmsg_auth_session()

  def handle_packet(
        <<_::unsigned-big-integer-size(16), @cmsg_auth_session::unsigned-little-integer-size(32),
          msg::binary>>,
        state = %Acceptor{}
      ) do
    CmsgAuthSession.handle_packet(msg, state)
  end

  # def handle_packet(

  # ) do

  # end
end
