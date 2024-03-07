defmodule Shared.Data.Dbc.Map do
  @moduledoc """
  Map data.
  """
  alias Shared.Data.Dbc.AreaTable
  # alias Shared.Data.Dbc.LoadingScreen
  alias Shared.Data.Dbc.TranslatableString

  use Ecto.Schema

  @primary_key {:id, :id, []}
  embedded_schema do
    field(:instance_type, Ecto.Enum, values: [continent: 0, dungeon: 1, raid: 2, battleground: 3])
    field(:pvp, :boolean, default: false)
    embeds_one(:name, TranslatableString)
    field(:minimum_level, :integer, default: 0)
    field(:maximum_level, :integer, default: 0)
    field(:maximum_players, :integer, default: 0)
    embeds_one(:area_table, AreaTable)
    # Do we need this?
    # embeds_one(:loading_screen, LoadingScreen)
  end

  def azeroth,
    do: %__MODULE__{
      id: 0,
      instance_type: :continent,
      pvp: false,
      name: %TranslatableString{en: "Azeroth"},
      minimum_level: 0,
      maximum_level: 0,
      maximum_players: 0,
      area_table: AreaTable.none()
    }

  def kalimdor,
    do: %__MODULE__{
      id: 1,
      instance_type: :continent,
      pvp: false,
      name: %TranslatableString{en: "Kalimdor"},
      minimum_level: 0,
      maximum_level: 0,
      maximum_players: 0,
      area_table: AreaTable.none()
    }

  def test,
    do: %__MODULE__{
      id: 13,
      instance_type: :continent,
      pvp: false,
      name: %TranslatableString{en: "Testing"},
      minimum_level: 0,
      maximum_level: 0,
      maximum_players: 0,
      area_table: AreaTable.none()
    }

  def scott_test,
    do: %__MODULE__{
      id: 25,
      instance_type: :continent,
      pvp: false,
      name: %TranslatableString{en: "Scott Test"},
      minimum_level: 0,
      maximum_level: 0,
      maximum_players: 0,
      area_table: AreaTable.none()
    }

  def test1,
    do: %__MODULE__{
      id: 29,
      instance_type: :dungeon,
      pvp: false,
      name: %TranslatableString{en: "Cash Test"},
      minimum_level: 0,
      maximum_level: 0,
      maximum_players: 0,
      area_table: AreaTable.none()
    }

  def pvp_zone_01,
    do: %__MODULE__{
      id: 30,
      instance_type: :battleground,
      pvp: true,
      name: %TranslatableString{en: "Alterac Valley"},
      minimum_level: 51,
      maximum_level: 60,
      maximum_players: 40,
      area_table: AreaTable.none()
    }

  def shadowfang,
    do: %__MODULE__{
      id: 209,
      instance_type: :dungeon,
      pvp: false,
      name: %TranslatableString{en: "Shadowfang Keep"},
      minimum_level: 0,
      maximum_level: 0,
      maximum_players: 0,
      area_table: AreaTable.none()
    }
end
