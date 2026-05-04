defmodule Game.Proto.Packet.SmsgPong do
  @moduledoc """
  SMSG_PONG is a World Packet that is sent as a response to a CMSG_PING from the client.
  """
  alias Game.Proto.Opcodes
  alias Game.Proto.Packet.Serializer

  require Logger

  @type t() :: %__MODULE__{sequence_id: non_neg_integer(), opcode: 0x1DD}

  @enforce_keys [:sequence_id]

  defstruct [:sequence_id, opcode: Opcodes.smsg_pong()]

  @spec new(params :: Enumerable.t()) :: t()
  def new(params), do: struct(__MODULE__, params)

  @spec to_binary(t(), binary(), non_neg_integer()) ::
          {[nonempty_binary(), ...], non_neg_integer()}
  def to_binary(packet = %__MODULE__{}, encryption_key, key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.sequence_id::unsigned-little-integer-size(32)>>
    ]
    |> Serializer.add_size()
    |> Serializer.encrypt_header(encryption_key, key_state)
  end
end
