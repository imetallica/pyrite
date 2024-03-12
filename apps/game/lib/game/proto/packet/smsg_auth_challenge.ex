defmodule Game.Proto.Packet.SmsgAuthChallenge do
  @moduledoc """
  Handles the smsg_auth_challenge packet.
  """
  alias Game.Proto.Opcodes

  @type t() :: %__MODULE__{
          challenge: non_neg_integer(),
          opcode: 0x1EC
        }

  @enforce_keys [:challenge]

  defstruct [
    :challenge,
    opcode: Opcodes.smsg_auth_challenge()
  ]

  def new,
    do: %__MODULE__{
      challenge: :crypto.bytes_to_integer(:crypto.strong_rand_bytes(4))
    }

  @spec to_binary(t()) :: [binary()]
  def to_binary(%__MODULE__{} = packet),
    do: [
      <<6::unsigned-big-integer-size(16)>>,
      <<packet.opcode::little-integer-size(16)>>,
      <<packet.challenge::unsigned-little-integer-size(32)>>
    ]
end
