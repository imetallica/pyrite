defmodule Shared.Data.Dbc.AreaTable do
  @moduledoc """
  AreaTable data.
  """
  alias Shared.Data.Dbc.TranslatableString
  alias Shared.Data.Dbc.Map

  use Ecto.Schema

  @primary_key {:id, :id, []}
  embedded_schema do
    embeds_one(:continent_id, Map)
    embeds_one(:parent_area_id, __MODULE__)
    field(:area_bit, :integer)
    field(:flags, :integer)
    field(:exploration_level, :integer)
    embeds_one(:area_name, TranslatableString)
    field(:faction_group_mask, Ecto.Enum, values: [none: 0, alliance: 2, horde: 4])
    field(:light_id, :integer)
  end

  def none, do: %__MODULE__{id: 0}

  def dun_moron,
    do: %__MODULE__{
      id: 1,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 119,
      flags: 65,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Dun Moron"},
      faction_group_mask: :alliance,
      light_id: 0
    }

  def longshore,
    do: %__MODULE__{
      id: 2,
      continent_id: Map.azeroth(),
      parent_area_id: westfall(),
      area_bit: 120,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Longshore"},
      faction_group_mask: :none,
      light_id: 0
    }

  def badlands,
    do: %__MODULE__{
      id: 3,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 121,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Badlands"},
      faction_group_mask: :none,
      light_id: 0
    }

  def blasted_lands,
    do: %__MODULE__{
      id: 4,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 122,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Blasted Lands"},
      faction_group_mask: :none,
      light_id: 0
    }

  def blackwater_cove,
    do: %__MODULE__{
      id: 7,
      continent_id: Map.azeroth(),
      parent_area_id: stranglethorn_vale(),
      area_bit: 123,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Blackwater Cove"},
      faction_group_mask: :none,
      light_id: 0
    }

  def swamp_of_sorrows,
    do: %__MODULE__{
      id: 8,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 124,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Swamp of Sorrows"},
      faction_group_mask: :none,
      light_id: 0
    }

  def northshire_valley,
    do: %__MODULE__{
      id: 9,
      continent_id: Map.azeroth(),
      parent_area_id: elwynn_forest(),
      area_bit: 125,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Northshire Valley"},
      faction_group_mask: :none,
      light_id: 0
    }

  def duskwood,
    do: %__MODULE__{
      id: 10,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 617,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Duskwood"},
      faction_group_mask: :none,
      light_id: 0
    }

  def wetlands,
    do: %__MODULE__{
      id: 11,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 618,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Wetlands"},
      faction_group_mask: :none,
      light_id: 0
    }

  def elwynn_forest,
    do: %__MODULE__{
      id: 12,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 126,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Elwynn Forest"},
      faction_group_mask: :alliance,
      light_id: 0
    }

  def stranglethorn_vale,
    do: %__MODULE__{
      id: 33,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 140,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Stranglethorn Vale"},
      faction_group_mask: :none,
      light_id: 0
    }

  def westfall,
    do: %__MODULE__{
      id: 40,
      continent_id: Map.azeroth(),
      parent_area_id: none(),
      area_bit: 146,
      flags: 64,
      exploration_level: 0,
      area_name: %TranslatableString{en: "Westfall"},
      faction_group_mask: :alliance,
      light_id: 0
    }
end
