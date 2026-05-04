defmodule Game.Proto.Packet.SmsgCharCreate do
  @moduledoc """
  SMSG_CHAR_CREATE is a World Packet sent in response to CMSG_CHAR_CREATE.
  Contains only a single-byte result code.
  """
  alias Game.Proto.Opcodes
  alias Shared.BinaryData
  alias Shared.Crypto

  @type t() :: %__MODULE__{
          result: non_neg_integer(),
          opcode: non_neg_integer()
        }

  @enforce_keys [:result]

  defstruct [:result, opcode: Opcodes.smsg_char_create()]

  @spec new(Enumerable.t()) :: t()
  def new(params), do: struct(__MODULE__, params)

  @spec to_binary(t(), binary(), non_neg_integer()) ::
          {[nonempty_binary(), ...], non_neg_integer()}
  def to_binary(%__MODULE__{} = packet, encryption_key, key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-integer-size(8)>>
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
