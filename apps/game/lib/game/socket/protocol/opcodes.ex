defmodule Game.Socket.Protocol.Opcodes do
  @moduledoc """
  This module contains all the opcodes used in the Game server.
  """

  def smsg_auth_challenge, do: 0x1EC
  def cmsg_auth_session, do: 0x1ED
  def smsg_auth_response, do: 0x1EE
end
