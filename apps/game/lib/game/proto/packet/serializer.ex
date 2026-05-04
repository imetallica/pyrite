defmodule Game.Proto.Packet.Serializer do
  @moduledoc """
  Shared serialisation helpers for SMSG (server-to-client) packets.

  Every SMSG module that sends an encrypted response uses the same
  `add_size/1` and `encrypt_header/3` logic.  This module centralises
  those functions so each packet module only contains its own
  payload-specific encoding.
  """

  alias Shared.BinaryData
  alias Shared.Crypto

  @spec add_size([binary()]) :: [binary()]
  def add_size(packets) do
    size = Enum.reduce(packets, 0, &(byte_size(&1) + &2))
    [<<size::unsigned-big-integer-size(16)>> | packets]
  end

  @spec encrypt_header([binary()], binary(), Crypto.Keystate.t()) ::
          {[binary()], Crypto.Keystate.t()}
  def encrypt_header(packet, encryption_key, key_state) do
    encryption_key = BinaryData.to_little_endian(encryption_key, byte_size(encryption_key) * 8)

    {data, new_key_state} = Crypto.encrypt(Enum.take(packet, 2), encryption_key, key_state)

    {[
       data
       | Enum.slice(packet, 2..Enum.count(packet))
     ], new_key_state}
  end
end
