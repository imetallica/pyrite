defmodule Game.Proto.Packet.SmsgCharEnum.Character do
  @equipment_slots 20

  defstruct [
    :guid,
    :name,
    :race,
    :class,
    :gender,
    :skin,
    :face,
    :hairstyle,
    :haircolor,
    :facialhair,
    :level,
    :area,
    :map,
    :position_x,
    :position_y,
    :position_z,
    :guild_id,
    :flags,
    :first_login,
    :pet_display_id,
    :pet_level,
    :pet_family,
    equipment: []
  ]

  @type equipment_slot :: %{display_id: non_neg_integer(), inventory_type: non_neg_integer()}
  @type t() :: %__MODULE__{
          guid: non_neg_integer(),
          name: String.t(),
          race: non_neg_integer(),
          class: non_neg_integer(),
          gender: non_neg_integer(),
          skin: non_neg_integer(),
          face: non_neg_integer(),
          hairstyle: non_neg_integer(),
          haircolor: non_neg_integer(),
          facialhair: non_neg_integer(),
          level: non_neg_integer(),
          area: non_neg_integer(),
          map: non_neg_integer(),
          position_x: float(),
          position_y: float(),
          position_z: float(),
          guild_id: non_neg_integer(),
          flags: non_neg_integer(),
          first_login: non_neg_integer(),
          pet_display_id: non_neg_integer(),
          pet_level: non_neg_integer(),
          pet_family: non_neg_integer(),
          equipment: [equipment_slot()]
        }

  @spec equipment_slots() :: non_neg_integer()
  def equipment_slots, do: @equipment_slots
end
