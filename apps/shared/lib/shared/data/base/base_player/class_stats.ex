defmodule Shared.Data.Base.BasePlayer.ClassStats do
  @moduledoc """
  Base health and mana per class at a given level.
  Sourced from the mangos `player_classlevelstats` table.
  """
  alias Shared.Data.Dbc.ChrClasses

  use Ecto.Schema

  @type t() :: %__MODULE__{base_health: non_neg_integer(), base_mana: non_neg_integer()}

  @primary_key false
  embedded_schema do
    field(:base_health, :integer, default: 0)
    field(:base_mana, :integer, default: 0)
  end

  @warrior ChrClasses.warrior()
  @paladin ChrClasses.paladin()
  @hunter ChrClasses.hunter()
  @rogue ChrClasses.rogue()
  @priest ChrClasses.priest()
  @shaman ChrClasses.shaman()
  @mage ChrClasses.mage()
  @warlock ChrClasses.warlock()
  @druid ChrClasses.druid()

  @spec new(non_neg_integer(), ChrClasses.t()) :: t()
  def new(1, @warrior), do: %__MODULE__{base_health: 20, base_mana: 0}
  def new(1, @paladin), do: %__MODULE__{base_health: 28, base_mana: 59}
  def new(1, @hunter), do: %__MODULE__{base_health: 26, base_mana: 63}
  def new(1, @rogue), do: %__MODULE__{base_health: 25, base_mana: 0}
  def new(1, @priest), do: %__MODULE__{base_health: 31, base_mana: 110}
  def new(1, @shaman), do: %__MODULE__{base_health: 27, base_mana: 53}
  def new(1, @mage), do: %__MODULE__{base_health: 31, base_mana: 100}
  def new(1, @warlock), do: %__MODULE__{base_health: 23, base_mana: 59}
  def new(1, @druid), do: %__MODULE__{base_health: 33, base_mana: 17}
end
