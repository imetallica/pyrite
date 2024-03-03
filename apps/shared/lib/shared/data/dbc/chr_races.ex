defmodule Shared.Data.Dbc.ChrRaces do
  @moduledoc """
  ChrRaces data.
  """
  alias Shared.Data.Dbc.Faction
  alias Shared.Data.Dbc.TranslatableString

  use Ecto.Schema

  @primary_key {:id, :id, []}
  embedded_schema do
    embeds_one(:faction, Faction)
    field(:male_display_id, :integer)
    field(:female_display_id, :integer)
    field(:base_language, :integer)
    field(:starting_taxi, :integer)
    field(:cinematic_sequence_id, :integer)
    embeds_one(:name, TranslatableString)
  end

  def human,
    do: %__MODULE__{
      id: 1,
      faction: Faction.player_human(),
      male_display_id: 49,
      female_display_id: 50,
      base_language: 7,
      starting_taxi: 2,
      cinematic_sequence_id: 81,
      name: %TranslatableString{en: "Human"}
    }

  def orc,
    do: %__MODULE__{
      id: 2,
      faction: Faction.player_orc(),
      male_display_id: 51,
      female_display_id: 52,
      base_language: 1,
      starting_taxi: 4_194_304,
      cinematic_sequence_id: 21,
      name: %TranslatableString{en: "Orc"}
    }

  def dwarf,
    do: %__MODULE__{
      id: 3,
      faction: Faction.player_dwarf(),
      male_display_id: 53,
      female_display_id: 54,
      base_language: 7,
      starting_taxi: 32,
      cinematic_sequence_id: 41,
      name: %TranslatableString{en: "Dwarf"}
    }

  def nightelf,
    do: %__MODULE__{
      id: 4,
      faction: Faction.player_nightelf(),
      male_display_id: 55,
      female_display_id: 56,
      base_language: 7,
      starting_taxi: 100_663_296,
      cinematic_sequence_id: 61,
      name: %TranslatableString{en: "Night Elf"}
    }

  def scourge,
    do: %__MODULE__{
      id: 5,
      faction: Faction.player_undead(),
      male_display_id: 57,
      female_display_id: 58,
      base_language: 1,
      starting_taxi: 1024,
      cinematic_sequence_id: 2,
      name: %TranslatableString{en: "Undead"}
    }

  def tauren,
    do: %__MODULE__{
      id: 6,
      faction: Faction.player_tauren(),
      male_display_id: 59,
      female_display_id: 60,
      base_language: 1,
      starting_taxi: 2_097_152,
      cinematic_sequence_id: 141,
      name: %TranslatableString{en: "Tauren"}
    }

  def gnome,
    do: %__MODULE__{
      id: 7,
      faction: Faction.player_gnome(),
      male_display_id: 1563,
      female_display_id: 1564,
      base_language: 7,
      starting_taxi: 32,
      cinematic_sequence_id: 101,
      name: %TranslatableString{en: "Gnome"}
    }

  def troll,
    do: %__MODULE__{
      id: 8,
      faction: Faction.player_troll(),
      male_display_id: 1478,
      female_display_id: 1479,
      base_language: 1,
      starting_taxi: 4_194_304,
      cinematic_sequence_id: 121,
      name: %TranslatableString{en: "Troll"}
    }

  def goblin,
    do: %__MODULE__{
      id: 9,
      faction: Faction.player_human(),
      male_display_id: 1140,
      female_display_id: 1140,
      base_language: 7,
      starting_taxi: 0,
      cinematic_sequence_id: 0,
      name: %TranslatableString{en: "Goblin"}
    }
end
