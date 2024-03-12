defmodule Game.Proto.Packet.SmsgAuthResponse do
  @moduledoc """
  It is a response to CMSG_AUTH_SESSION. It is followed by a CMSG_CHAR_ENUM from the client.
  """
  alias Game.Proto.AccountResultValues
  alias Game.Proto.Opcodes
  alias Shared.BinaryData
  alias Shared.Crypto

  @type t() :: %__MODULE__{
          opcode: 0x1EE,
          result:
            AccountResultValues.auth_ok()
            | AccountResultValues.auth_wait_queue()
            | AccountResultValues.auth_unknown_account()
            | AccountResultValues.auth_banned()
            | AccountResultValues.auth_suspended()
            | AccountResultValues.auth_version_mismatch()
            | AccountResultValues.auth_reject(),
          # If the result is AUTH_OK or AUTH_WAIT_QUEUE this segment is required.
          billing_time: binary(),
          billing_flags: binary(),
          billing_rested: binary(),
          # If the result is AUTH_WAIT_QUEUE this segment is required.
          queue_position: non_neg_integer() | nil
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

  @auth_ok AccountResultValues.auth_ok()
  @auth_wait_queue AccountResultValues.auth_wait_queue()

  @spec to_binary(Game.Proto.Packet.SmsgAuthResponse.t()) :: [nonempty_binary(), ...]
  def to_binary(%__MODULE__{} = packet) do
    add_size([
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-little-integer-size(32)>>
    ])
  end

  @spec to_binary(Game.Proto.Packet.SmsgAuthResponse.t(), binary(), non_neg_integer()) ::
          {[nonempty_binary(), ...], non_neg_integer()}
  def to_binary(%__MODULE__{result: @auth_ok} = packet, encryption_key, current_key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-little-integer-size(32)>>,
      <<packet.billing_time::unsigned-little-integer-size(32)>>,
      <<packet.billing_flags::unsigned-big-integer-size(8)>>,
      <<packet.billing_rested::unsigned-little-integer-size(32)>>
    ]
    |> add_size()
    |> encrypt_header(encryption_key, current_key_state)
  end

  def to_binary(%__MODULE__{result: @auth_wait_queue} = packet, encryption_key, current_key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-little-integer-size(32)>>,
      <<packet.billing_time::unsigned-little-integer-size(32)>>,
      <<packet.billing_flags::unsigned-big-integer-size(8)>>,
      <<packet.billing_rested::unsigned-little-integer-size(32)>>,
      <<packet.queue_position::unsigned-little-integer-size(32)>>
    ]
    |> add_size()
    |> encrypt_header(encryption_key, current_key_state)
  end

  def to_binary(%__MODULE__{} = packet, encryption_key, current_key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-little-integer-size(32)>>
    ]
    |> add_size()
    |> encrypt_header(encryption_key, current_key_state)
  end

  defp add_size(packets) do
    size = Enum.reduce(packets, 0, &(byte_size(&1) + &2))
    [<<size::unsigned-big-integer-size(16)>> | packets]
  end

  defp encrypt_header(packet, encryption_key, current_key_state) do
    encryption_key = BinaryData.to_little_endian(encryption_key, byte_size(encryption_key) * 8)

    {data, new_key_state} =
      Crypto.encrypt(Enum.take(packet, 2), encryption_key, current_key_state)

    {[
       data
       | Enum.slice(packet, 2..Enum.count(packet))
     ], new_key_state}
  end
end
