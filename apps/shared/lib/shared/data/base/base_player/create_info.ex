defmodule Shared.Data.Base.BasePlayer.CreateInfo do
  @moduledoc """
  Starting position, map, zone, and class stats per race/class combination.
  Sourced from the mangos `playercreateinfo` table.
  """
  alias Shared.Data.Base.BasePlayer.ClassStats
  alias Shared.Data.Dbc.ChrClasses
  alias Shared.Data.Dbc.ChrRaces

  use Ecto.Schema

  @type t() :: %__MODULE__{
          race: atom(),
          class: atom(),
          map: atom(),
          zone: atom(),
          position: %{x: float(), y: float(), z: float(), orientation: float()},
          class_stats: ClassStats.t()
        }

  @primary_key false
  embedded_schema do
    field(:race, :string)
    field(:class, :string)
    field(:map, :string)
    field(:zone, :string)
    field(:position, :map)
    embeds_one(:class_stats, ClassStats)
  end

  # Race DBC structs
  @human ChrRaces.human()
  @orc ChrRaces.orc()
  @dwarf ChrRaces.dwarf()
  @nightelf ChrRaces.nightelf()
  @forsaken ChrRaces.scourge()
  @tauren ChrRaces.tauren()
  @gnome ChrRaces.gnome()
  @troll ChrRaces.troll()

  # Class DBC structs
  @warrior ChrClasses.warrior()
  @paladin ChrClasses.paladin()
  @hunter ChrClasses.hunter()
  @rogue ChrClasses.rogue()
  @priest ChrClasses.priest()
  @shaman ChrClasses.shaman()
  @mage ChrClasses.mage()
  @warlock ChrClasses.warlock()
  @druid ChrClasses.druid()

  # Starting positions per race (from mangos playercreateinfo)
  @human_position %{x: -8949.95, y: -132.493, z: 83.5312, orientation: 0.0}
  @orc_position %{x: -618.518, y: -4251.67, z: 38.718, orientation: 0.0}
  @dwarf_position %{x: -6240.32, y: 331.033, z: 382.758, orientation: 6.17716}
  @nightelf_position %{x: 10_311.3, y: 832.463, z: 1326.41, orientation: 5.69632}
  @forsaken_position %{x: 1676.71, y: 1678.31, z: 121.67, orientation: 2.70526}
  @tauren_position %{x: -2917.58, y: -257.98, z: 52.9968, orientation: 0.0}
  @gnome_position %{x: -6240.32, y: 331.033, z: 382.758, orientation: 0.0}
  @troll_position %{x: -618.518, y: -4251.67, z: 38.718, orientation: 0.0}

  @spec new(ChrRaces.t(), ChrClasses.t()) :: t() | nil

  # Human (azeroth, elwynn_forest)
  def new(@human, @warrior),
    do: build(:human, :warrior, :azeroth, :elwynn_forest, @human_position, @warrior)

  def new(@human, @paladin),
    do: build(:human, :paladin, :azeroth, :elwynn_forest, @human_position, @paladin)

  def new(@human, @rogue),
    do: build(:human, :rogue, :azeroth, :elwynn_forest, @human_position, @rogue)

  def new(@human, @priest),
    do: build(:human, :priest, :azeroth, :elwynn_forest, @human_position, @priest)

  def new(@human, @mage),
    do: build(:human, :mage, :azeroth, :elwynn_forest, @human_position, @mage)

  def new(@human, @warlock),
    do: build(:human, :warlock, :azeroth, :elwynn_forest, @human_position, @warlock)

  # Orc (kalimdor, durotar)
  def new(@orc, @warrior),
    do: build(:orc, :warrior, :kalimdor, :durotar, @orc_position, @warrior)

  def new(@orc, @hunter),
    do: build(:orc, :hunter, :kalimdor, :durotar, @orc_position, @hunter)

  def new(@orc, @rogue),
    do: build(:orc, :rogue, :kalimdor, :durotar, @orc_position, @rogue)

  def new(@orc, @shaman),
    do: build(:orc, :shaman, :kalimdor, :durotar, @orc_position, @shaman)

  def new(@orc, @warlock),
    do: build(:orc, :warlock, :kalimdor, :durotar, @orc_position, @warlock)

  # Dwarf (azeroth, dun_moron)
  def new(@dwarf, @warrior),
    do: build(:dwarf, :warrior, :azeroth, :dun_moron, @dwarf_position, @warrior)

  def new(@dwarf, @paladin),
    do: build(:dwarf, :paladin, :azeroth, :dun_moron, @dwarf_position, @paladin)

  def new(@dwarf, @hunter),
    do: build(:dwarf, :hunter, :azeroth, :dun_moron, @dwarf_position, @hunter)

  def new(@dwarf, @rogue),
    do: build(:dwarf, :rogue, :azeroth, :dun_moron, @dwarf_position, @rogue)

  def new(@dwarf, @priest),
    do: build(:dwarf, :priest, :azeroth, :dun_moron, @dwarf_position, @priest)

  # Night Elf (kalimdor, teldrassil)
  def new(@nightelf, @warrior),
    do: build(:nightelf, :warrior, :kalimdor, :teldrassil, @nightelf_position, @warrior)

  def new(@nightelf, @hunter),
    do: build(:nightelf, :hunter, :kalimdor, :teldrassil, @nightelf_position, @hunter)

  def new(@nightelf, @rogue),
    do: build(:nightelf, :rogue, :kalimdor, :teldrassil, @nightelf_position, @rogue)

  def new(@nightelf, @priest),
    do: build(:nightelf, :priest, :kalimdor, :teldrassil, @nightelf_position, @priest)

  def new(@nightelf, @druid),
    do: build(:nightelf, :druid, :kalimdor, :teldrassil, @nightelf_position, @druid)

  # Forsaken (azeroth, tirisfal_glades)
  def new(@forsaken, @warrior),
    do: build(:forsaken, :warrior, :azeroth, :tirisfal_glades, @forsaken_position, @warrior)

  def new(@forsaken, @rogue),
    do: build(:forsaken, :rogue, :azeroth, :tirisfal_glades, @forsaken_position, @rogue)

  def new(@forsaken, @priest),
    do: build(:forsaken, :priest, :azeroth, :tirisfal_glades, @forsaken_position, @priest)

  def new(@forsaken, @mage),
    do: build(:forsaken, :mage, :azeroth, :tirisfal_glades, @forsaken_position, @mage)

  def new(@forsaken, @warlock),
    do: build(:forsaken, :warlock, :azeroth, :tirisfal_glades, @forsaken_position, @warlock)

  # Tauren (kalimdor, mulgore)
  def new(@tauren, @warrior),
    do: build(:tauren, :warrior, :kalimdor, :mulgore, @tauren_position, @warrior)

  def new(@tauren, @hunter),
    do: build(:tauren, :hunter, :kalimdor, :mulgore, @tauren_position, @hunter)

  def new(@tauren, @shaman),
    do: build(:tauren, :shaman, :kalimdor, :mulgore, @tauren_position, @shaman)

  def new(@tauren, @druid),
    do: build(:tauren, :druid, :kalimdor, :mulgore, @tauren_position, @druid)

  # Gnome (azeroth, dun_moron)
  def new(@gnome, @warrior),
    do: build(:gnome, :warrior, :azeroth, :dun_moron, @gnome_position, @warrior)

  def new(@gnome, @rogue),
    do: build(:gnome, :rogue, :azeroth, :dun_moron, @gnome_position, @rogue)

  def new(@gnome, @mage),
    do: build(:gnome, :mage, :azeroth, :dun_moron, @gnome_position, @mage)

  def new(@gnome, @warlock),
    do: build(:gnome, :warlock, :azeroth, :dun_moron, @gnome_position, @warlock)

  # Troll (kalimdor, durotar)
  def new(@troll, @warrior),
    do: build(:troll, :warrior, :kalimdor, :durotar, @troll_position, @warrior)

  def new(@troll, @hunter),
    do: build(:troll, :hunter, :kalimdor, :durotar, @troll_position, @hunter)

  def new(@troll, @rogue),
    do: build(:troll, :rogue, :kalimdor, :durotar, @troll_position, @rogue)

  def new(@troll, @priest),
    do: build(:troll, :priest, :kalimdor, :durotar, @troll_position, @priest)

  def new(@troll, @shaman),
    do: build(:troll, :shaman, :kalimdor, :durotar, @troll_position, @shaman)

  def new(@troll, @mage),
    do: build(:troll, :mage, :kalimdor, :durotar, @troll_position, @mage)

  def new(_race, _class), do: nil

  @spec all() :: [t()]
  def all do
    [
      new(ChrRaces.human(), ChrClasses.warrior()),
      new(ChrRaces.human(), ChrClasses.paladin()),
      new(ChrRaces.human(), ChrClasses.rogue()),
      new(ChrRaces.human(), ChrClasses.priest()),
      new(ChrRaces.human(), ChrClasses.mage()),
      new(ChrRaces.human(), ChrClasses.warlock()),
      new(ChrRaces.orc(), ChrClasses.warrior()),
      new(ChrRaces.orc(), ChrClasses.hunter()),
      new(ChrRaces.orc(), ChrClasses.rogue()),
      new(ChrRaces.orc(), ChrClasses.shaman()),
      new(ChrRaces.orc(), ChrClasses.warlock()),
      new(ChrRaces.dwarf(), ChrClasses.warrior()),
      new(ChrRaces.dwarf(), ChrClasses.paladin()),
      new(ChrRaces.dwarf(), ChrClasses.hunter()),
      new(ChrRaces.dwarf(), ChrClasses.rogue()),
      new(ChrRaces.dwarf(), ChrClasses.priest()),
      new(ChrRaces.nightelf(), ChrClasses.warrior()),
      new(ChrRaces.nightelf(), ChrClasses.hunter()),
      new(ChrRaces.nightelf(), ChrClasses.rogue()),
      new(ChrRaces.nightelf(), ChrClasses.priest()),
      new(ChrRaces.nightelf(), ChrClasses.druid()),
      new(ChrRaces.scourge(), ChrClasses.warrior()),
      new(ChrRaces.scourge(), ChrClasses.rogue()),
      new(ChrRaces.scourge(), ChrClasses.priest()),
      new(ChrRaces.scourge(), ChrClasses.mage()),
      new(ChrRaces.scourge(), ChrClasses.warlock()),
      new(ChrRaces.tauren(), ChrClasses.warrior()),
      new(ChrRaces.tauren(), ChrClasses.hunter()),
      new(ChrRaces.tauren(), ChrClasses.shaman()),
      new(ChrRaces.tauren(), ChrClasses.druid()),
      new(ChrRaces.gnome(), ChrClasses.warrior()),
      new(ChrRaces.gnome(), ChrClasses.rogue()),
      new(ChrRaces.gnome(), ChrClasses.mage()),
      new(ChrRaces.gnome(), ChrClasses.warlock()),
      new(ChrRaces.troll(), ChrClasses.warrior()),
      new(ChrRaces.troll(), ChrClasses.hunter()),
      new(ChrRaces.troll(), ChrClasses.rogue()),
      new(ChrRaces.troll(), ChrClasses.priest()),
      new(ChrRaces.troll(), ChrClasses.shaman()),
      new(ChrRaces.troll(), ChrClasses.mage())
    ]
  end

  defp build(race, class, map, zone, position, class_struct) do
    %__MODULE__{
      race: race,
      class: class,
      map: map,
      zone: zone,
      position: position,
      class_stats: ClassStats.new(1, class_struct)
    }
  end
end
