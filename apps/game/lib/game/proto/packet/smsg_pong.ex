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

  @spec to_binary(t(), binary()) :: list(binary())
  def to_binary(%__MODULE__{} = packet, encryption_key) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.sequence_id::unsigned-little-integer-size(32)>>
    ]
    |> add_size()
    |> encrypt_header(encryption_key)
  end

  defp add_size(packets) do
    size = Enum.reduce(packets, 0, &(byte_size(&1) + &2))
    [<<size::unsigned-big-integer-size(16)>> | packets]
  end

  defp encrypt_header(packet, encryption_key) do
    encryption_key = BinaryData.to_little_endian(encryption_key, byte_size(encryption_key) * 8)

    [
      Crypto.encrypt(Enum.take(packet, 2), encryption_key)
      | Enum.slice(packet, 2..Enum.count(packet))
    ]
  end
end
