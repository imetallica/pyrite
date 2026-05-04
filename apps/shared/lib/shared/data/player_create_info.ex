defmodule Shared.Data.PlayerCreateInfo do
  @moduledoc """
  Starting player data per race/class combination.
  Sourced from the mangos `playercreateinfo` and `player_classlevelstats` tables.
  """

  @type position :: %{x: float(), y: float(), z: float(), orientation: float()}
  @type t() :: %__MODULE__{
          race: atom(),
          class: atom(),
          map: atom(),
          zone: atom(),
          position: position(),
          base_health: non_neg_integer(),
          base_mana: non_neg_integer()
        }

  @enforce_keys [:race, :class, :map, :zone, :position, :base_health, :base_mana]
  defstruct [:race, :class, :map, :zone, :position, :base_health, :base_mana]

  @spec for(atom(), atom()) :: t() | nil
  def for(:human, :warrior) do
    %__MODULE__{
      race: :human,
      class: :warrior,
      map: :azeroth,
      zone: :elwynn_forest,
      position: %{x: -8949.95, y: -132.493, z: 83.5312, orientation: 0.0},
      base_health: 20,
      base_mana: 0
    }
  end

  def for(_race, _class), do: nil
end
