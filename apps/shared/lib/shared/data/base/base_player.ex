defmodule Shared.Data.Base.BasePlayer do
  @moduledoc """
  This module represents a player in the emulator. It contains all relevant
  information about them, such as name, race, class, level, and more.
  """
  alias Shared.Data.Base.BasePlayer.ClassStats
  alias Shared.Data.Base.BasePlayer.RaceStats
  alias Shared.Data.Dbc.ChrRaces
  alias Shared.Data.Dbc.ChrClasses

  use Ecto.Schema

  @race_human ChrRaces.human().id
  @race_dwarf ChrRaces.dwarf().id
  @race_nightelf ChrRaces.nightelf().id
  @race_gnome ChrRaces.gnome().id
  @race_orc ChrRaces.orc().id
  @race_troll ChrRaces.troll().id
  @race_undead ChrRaces.scourge().id
  @race_tauren ChrRaces.tauren().id

  @class_warrior ChrClasses.warrior().id
  @class_paladin ChrClasses.paladin().id
  @class_hunter ChrClasses.hunter().id
  @class_rogue ChrClasses.rogue().id
  @class_priest ChrClasses.priest().id
  @class_shaman ChrClasses.shaman().id
  @class_mage ChrClasses.mage().id
  @class_warlock ChrClasses.warlock().id
  @class_druid ChrClasses.druid().id

  @type t() :: %__MODULE__{
          level: non_neg_integer(),
          race: ChrRaces.t(),
          class: ChrClasses.t(),
          base_race_stats: RaceStats.t(),
          base_class_stats: ClassStats.t()
        }

  embedded_schema do
    field(:level, :integer)
    embeds_one(:race, ChrRaces)
    embeds_one(:class, ChrClasses)

    embeds_one(:base_race_stats, RaceStats)
    embeds_one(:base_class_stats, ClassStats)
  end

  @spec new(
          level :: non_neg_integer(),
          race :: ChrRaces.t(),
          class :: ChrClasses.t()
        ) :: t()
  def new(level, race, class),
    do: %__MODULE__{
      level: level,
      race: race,
      class: class,
      base_race_stats: RaceStats.new(level, race, class)
    }
end
