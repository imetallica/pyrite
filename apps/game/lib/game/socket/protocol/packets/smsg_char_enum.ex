defmodule Game.Socket.Protocol.Packets.SmsgCharEnum do
  @moduledoc """
  SMSG_CHAR_ENUM is a World Packet that is sent after a CMSG_CHAR_ENUM from the client.
  It takes the client to the character selection screen.
  """
  alias Game.Socket.Protocol.Opcodes

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

  defimpl Shared.BinaryPacketWithEncryptedHeaders do
    alias Game.Socket.Protocol.Packets.SmsgCharEnum.Character
    alias Game.Socket.Protocol.Packets.SmsgCharEnum
    alias Shared.BinaryData
    alias Shared.Crypto

    def to_binary(%SmsgCharEnum{} = packet, encryption_key) do
      [
        <<packet.amount_of_characters::unsigned-little-integer-size(8)>>,
        <<packet.opcode::unsigned-little-integer-size(16)>>
      ]
      |> add_characters(packet.characters)
      |> Enum.reverse()
      |> add_size()
      |> encrypt_header(encryption_key)
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

    defp encrypt_header(packet, encryption_key) do
      encryption_key = BinaryData.to_little_endian(encryption_key, byte_size(encryption_key) * 8)

      [
        Crypto.encrypt(Enum.take(packet, 2), encryption_key)
        | Enum.slice(packet, 2..Enum.count(packet))
      ]
    end
  end
end
