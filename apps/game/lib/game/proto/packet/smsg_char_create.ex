defmodule Game.Proto.Packet.SmsgCharCreate do
  @moduledoc """
  SMSG_CHAR_CREATE is a World Packet sent in response to CMSG_CHAR_CREATE.
  Contains only a single-byte result code.
  """
  alias Game.Proto.Opcodes
  alias Game.Proto.Packet.Serializer

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
  def to_binary(packet = %__MODULE__{}, encryption_key, key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-integer-size(8)>>
    ]
    |> Serializer.add_size()
    |> Serializer.encrypt_header(encryption_key, key_state)
  end
end
