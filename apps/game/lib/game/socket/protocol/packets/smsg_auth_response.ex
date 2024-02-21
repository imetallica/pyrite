defmodule Game.Socket.Protocol.Packets.SmsgAuthResponse do
  @moduledoc """
  It is a response to CMSG_AUTH_SESSION. It is followed by a CMSG_CHAR_ENUM from the client.
  """
  alias Shared.Crypto
  alias Game.Socket.Protocol.AccountResultValues
  alias Game.Socket.Protocol.Opcodes

  @type t() :: %__MODULE__{
          opcode: binary(),
          result: binary(),
          # If the result is AUTH_OK or AUTH_WAIT_QUEUE this segment is required.
          billing_time: binary(),
          billing_flags: binary(),
          billing_rested: binary(),
          # If the result is AUTH_WAIT_QUEUE this segment is required.
          queue_position: binary()
        }

  @enforce_keys [:result]

  defstruct [
    :result,
    :billing_time,
    :billing_flags,
    :billing_rested,
    :queue_position,
    opcode: Opcodes.smsg_auth_response()
  ]

  @spec new(Enumerable.t()) :: t()
  def new(params) do
    struct(__MODULE__, params)
  end

  defimpl Shared.BinaryPacketWithEncryptedHeaders do
    alias Game.Socket.Protocol.Packets.SmsgAuthResponse

    @auth_ok AccountResultValues.auth_ok()
    @auth_wait_queue AccountResultValues.auth_wait_queue()

    def to_binary(%SmsgAuthResponse{result: @auth_ok} = packet, encryption_key) do
      [
        <<packet.opcode::unsigned-little-integer-size(16)>>,
        <<packet.result::unsigned-little-integer-size(32)>>,
        <<packet.billing_time::unsigned-little-integer-size(32)>>,
        <<packet.billing_flags::unsigned-big-integer-size(8)>>,
        <<packet.billing_rested::unsigned-little-integer-size(32)>>
      ]
      |> add_size()
      |> encrypt_header(encryption_key)
    end

    def to_binary(%SmsgAuthResponse{result: @auth_wait_queue} = packet, encryption_key) do
      [
        <<packet.opcode::unsigned-little-integer-size(16)>>,
        <<packet.result::unsigned-little-integer-size(32)>>,
        <<packet.billing_time::unsigned-little-integer-size(32)>>,
        <<packet.billing_flags::unsigned-big-integer-size(8)>>,
        <<packet.billing_rested::unsigned-little-integer-size(32)>>,
        <<packet.queue_position::unsigned-little-integer-size(32)>>
      ]
      |> add_size()
      |> encrypt_header(encryption_key)
    end

    def to_binary(%SmsgAuthResponse{} = packet, encryption_key) do
      [
        <<packet.opcode::unsigned-little-integer-size(16)>>,
        <<packet.result::unsigned-little-integer-size(32)>>
      ]
      |> add_size()
      |> encrypt_header(encryption_key)
    end

    defp add_size(packets) do
      size = Enum.reduce(packets, 0, &(byte_size(&1) + &2))
      [<<size::unsigned-big-integer-size(16)>> | packets]
    end

    defp encrypt_header(packet, encryption_key) do
      [
        Crypto.encrypt(Enum.take(packet, 2), encryption_key)
        | Enum.slice(packet, 2..Enum.count(packet))
      ]
    end
  end
end
