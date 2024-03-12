defmodule Game.Proto.Packet.SmsgPong do
  @moduledoc """
  SMSG_PONG is a World Packet that is sent as a response to a CMSG_PING from the client.
  """
  alias Game.Proto.Opcodes
  alias Shared.BinaryData
  alias Shared.Crypto

  require Logger

  @type t() :: %__MODULE__{sequence_id: non_neg_integer(), opcode: 0x1DD}

  @enforce_keys [:sequence_id]

  defstruct [:sequence_id, opcode: Opcodes.smsg_pong()]

  @spec new(params :: Enumerable.t()) :: t()
  def new(params), do: struct(__MODULE__, params)

  @spec to_binary(t(), binary(), non_neg_integer()) ::
          {[nonempty_binary(), ...], non_neg_integer()}
  def to_binary(%__MODULE__{} = packet, encryption_key, key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.sequence_id::unsigned-little-integer-size(32)>>
    ]
    |> add_size()
    |> encrypt_header(encryption_key, key_state)
  end

  defp add_size(packets) do
    size = Enum.reduce(packets, 0, &(byte_size(&1) + &2))
    [<<size::unsigned-big-integer-size(16)>> | packets]
  end

  defp encrypt_header(packet, encryption_key, key_state) do
    encryption_key = BinaryData.to_little_endian(encryption_key, byte_size(encryption_key) * 8)

    {data, new_key_state} = Crypto.encrypt(Enum.take(packet, 2), encryption_key, key_state)

    {[
       data
       | Enum.slice(packet, 2..Enum.count(packet))
     ], new_key_state}
  end
end
