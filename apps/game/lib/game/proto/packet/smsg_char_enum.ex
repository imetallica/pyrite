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
          opcode: 0x1ED,
          amount_of_characters: non_neg_integer(),
          characters: []
        }

  @enforce_keys [:amount_of_characters, :characters]

  defstruct [:amount_of_characters, opcode: Opcodes.smsg_char_enum(), characters: []]

  @spec new(params :: Enumerable.t()) :: t()
  def new(params), do: struct(__MODULE__, params)

  @spec to_binary(t(), binary(), non_neg_integer()) ::
          {[nonempty_binary(), ...], non_neg_integer()}
  def to_binary(%__MODULE__{} = packet, encryption_key, key_state) do
    # Reverse order because well, we call Enum.reverse/1 at the end of the function
    [
      <<packet.amount_of_characters::unsigned-big-integer-size(8)>>,
      <<packet.opcode::unsigned-little-integer-size(16)>>
    ]
    |> add_characters(packet.characters)
    |> Enum.reverse()
    |> add_size()
    |> encrypt_header(encryption_key, key_state)
  end

  defp add_characters(acc, characters) do
    Enum.reduce(characters, acc, fn char = %Character{}, acc ->
      equipment_data = encode_equipment(char.equipment)

      [
        equipment_data,
        <<char.pet_family::unsigned-little-integer-size(32)>>,
        <<char.pet_level::unsigned-little-integer-size(32)>>,
        <<char.pet_display_id::unsigned-little-integer-size(32)>>,
        <<char.first_login::unsigned-integer-size(8)>>,
        <<char.flags::unsigned-little-integer-size(32)>>,
        <<char.guild_id::unsigned-little-integer-size(32)>>,
        <<char.position_z::float-little-32>>,
        <<char.position_y::float-little-32>>,
        <<char.position_x::float-little-32>>,
        <<char.map::unsigned-little-integer-size(32)>>,
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
        <<char.name::binary, 0>>,
        <<char.guid::unsigned-little-integer-size(64)>> | acc
      ]
    end)
  end

  defp encode_equipment(equipment) when is_list(equipment) do
    slot_count = Character.equipment_slots()

    equipment
    |> Enum.take(slot_count)
    |> Enum.map(fn %{display_id: display_id, inventory_type: inventory_type} ->
      <<display_id::unsigned-little-integer-size(32), inventory_type::unsigned-integer-size(8)>>
    end)
    |> then(fn slots ->
      current = length(slots)

      padding =
        List.duplicate(
          <<0::unsigned-little-integer-size(32), 0::unsigned-integer-size(8)>>,
          slot_count - current
        )

      slots ++ padding
    end)
    |> Enum.reduce(<<>>, &(&2 <> &1))
  end

  defp encode_equipment(_equipment) do
    List.duplicate(
      <<0::unsigned-little-integer-size(32), 0::unsigned-integer-size(8)>>,
      Character.equipment_slots()
    )
    |> Enum.reduce(<<>>, &(&2 <> &1))
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
