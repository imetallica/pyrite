defmodule Game.Proto.Packet.SmsgCharEnum do
  @moduledoc """
  SMSG_CHAR_ENUM is a World Packet that is sent after a CMSG_CHAR_ENUM from the client.
  It takes the client to the character selection screen.
  """
  alias Game.Proto.Opcodes
  alias Game.Proto.Packet.SmsgCharEnum.Character
  alias Shared.BinaryData
  alias Shared.Crypto

  require Logger

  @type t() :: %__MODULE__{
          opcode: Opcodes.cmsg_auth_session(),
          amount_of_characters: non_neg_integer(),
          characters: []
        }

  @enforce_keys [:amount_of_characters, :characters]

  defstruct [:amount_of_characters, opcode: Opcodes.smsg_pong(), characters: []]

  @spec new(params :: Enumerable.t()) :: t()
  def new(params), do: struct(__MODULE__, params)

  @spec to_binary(t(), binary(), non_neg_integer()) ::
          {[nonempty_binary(), ...], non_neg_integer()}
  def to_binary(%__MODULE__{} = packet, encryption_key, key_state) do
    [
      <<packet.amount_of_characters::unsigned-little-integer-size(8)>>,
      <<packet.opcode::unsigned-little-integer-size(16)>>
    ]
    |> add_characters(packet.characters)
    |> Enum.reverse()
    |> add_size()
    |> encrypt_header(encryption_key, key_state)
  end

  defp add_characters(acc, characters) do
    Enum.reduce(characters, acc, fn char = %Character{}, acc ->
      [
        <<char.pet_family::unsigned-little-integer-size(32)>>,
        <<char.pet_level::unsigned-little-integer-size(32)>>,
        <<char.pet_display_id::unsigned-little-integer-size(32)>>,
        <<char.first_login::size(1)>>,
        <<char.flags::unsigned-little-integer-size(32)>>,
        <<char.guild_id::unsigned-little-integer-size(32)>>,
        <<char.position_z::unsigned-little-float>>,
        <<char.position_y::unsigned-little-float>>,
        <<char.position_x::unsigned-little-float>>,
        <<char.map::unsigned-little-integer-size(8)>>,
        <<char.area::unsigned-little-integer-size(32)>>,
        <<char.level::unsigned-big-integer-size(8)>>,
        <<char.facialhair::unsigned-big-integer-size(8)>>,
        <<char.haircolor::unsigned-big-integer-size(8)>>,
        <<char.hairstyle::unsigned-big-integer-size(8)>>,
        <<char.face::unsigned-big-integer-size(8)>>,
        <<char.skin::unsigned-big-integer-size(8)>>,
        <<char.gender::unsigned-big-integer-size(8)>>,
        <<char.class::unsigned-big-integer-size(8)>>,
        <<char.race::unsigned-big-integer-size(8)>>,
        <<char.name::utf8>>,
        <<char.guid::unsigned-little-integer-size(64)>> | acc
      ]
    end)
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
