defmodule Game.Proto.Opcodes do
  @moduledoc """
  This module contains all the opcodes used.
  """

  def cmsg_char_create, do: 0x036
  def cmsg_char_enum, do: 0x037
  def smsg_char_enum, do: 0x03B
  def cmsg_ping, do: 0x1DC
  def smsg_pong, do: 0x1DD
  def smsg_auth_challenge, do: 0x1EC
  def cmsg_auth_session, do: 0x1ED
  def smsg_auth_response, do: 0x1EE
end
