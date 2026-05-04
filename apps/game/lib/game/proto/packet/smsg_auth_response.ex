defmodule Game.Proto.Packet.SmsgAuthResponse do
  @moduledoc """
  It is a response to CMSG_AUTH_SESSION. It is followed by a CMSG_CHAR_ENUM from the client.
  """
  alias Game.Proto.AccountResultValues
  alias Game.Proto.Opcodes
  alias Game.Proto.Packet.Serializer

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
  def new(params), do: struct(__MODULE__, params)

  @auth_ok AccountResultValues.auth_ok()
  @auth_wait_queue AccountResultValues.auth_wait_queue()

  @spec to_binary(Game.Proto.Packet.SmsgAuthResponse.t()) :: [nonempty_binary(), ...]
  def to_binary(packet = %__MODULE__{}) do
    Serializer.add_size([
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-little-integer-size(32)>>
    ])
  end

  @spec to_binary(Game.Proto.Packet.SmsgAuthResponse.t(), binary(), non_neg_integer()) ::
          {[nonempty_binary(), ...], non_neg_integer()}
  def to_binary(packet = %__MODULE__{result: @auth_ok}, encryption_key, current_key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-little-integer-size(32)>>,
      <<packet.billing_time::unsigned-little-integer-size(32)>>,
      <<packet.billing_flags::unsigned-big-integer-size(8)>>,
      <<packet.billing_rested::unsigned-little-integer-size(32)>>
    ]
    |> Serializer.add_size()
    |> Serializer.encrypt_header(encryption_key, current_key_state)
  end

  def to_binary(packet = %__MODULE__{result: @auth_wait_queue}, encryption_key, current_key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-little-integer-size(32)>>,
      <<packet.billing_time::unsigned-little-integer-size(32)>>,
      <<packet.billing_flags::unsigned-big-integer-size(8)>>,
      <<packet.billing_rested::unsigned-little-integer-size(32)>>,
      <<packet.queue_position::unsigned-little-integer-size(32)>>
    ]
    |> Serializer.add_size()
    |> Serializer.encrypt_header(encryption_key, current_key_state)
  end

  def to_binary(packet = %__MODULE__{}, encryption_key, current_key_state) do
    [
      <<packet.opcode::unsigned-little-integer-size(16)>>,
      <<packet.result::unsigned-little-integer-size(32)>>
    ]
    |> Serializer.add_size()
    |> Serializer.encrypt_header(encryption_key, current_key_state)
  end
end
