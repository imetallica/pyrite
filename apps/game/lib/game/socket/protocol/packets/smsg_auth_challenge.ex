defmodule Game.Socket.Protocol.Packets.SmsgAuthChallenge do
  @moduledoc """
  Handles the smsg_auth_challenge packet.
  """
  alias Game.Socket.Protocol.Opcodes

  @type t() :: %__MODULE__{
          challenge: binary(),
          opcode: binary()
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

  defimpl Shared.BinaryPacket do
    alias Game.Socket.Protocol.Packets.SmsgAuthChallenge

    def to_binary(%SmsgAuthChallenge{} = packet),
      do: [
        <<6::unsigned-big-integer-size(16)>>,
        <<packet.opcode::little-integer-size(16)>>,
        <<packet.challenge::unsigned-little-integer-size(32)>>
      ]
  end
end
