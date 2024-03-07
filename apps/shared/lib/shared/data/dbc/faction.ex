defmodule Shared.Data.Dbc.Faction do
  @moduledoc """
  Faction data.
  """
  alias Shared.Data.Dbc.Faction.ReputationBase
  alias Shared.Data.Dbc.Faction.ReputationClass
  alias Shared.Data.Dbc.Faction.ReputationFlag
  alias Shared.Data.Dbc.Faction.ReputationRace
  alias Shared.Data.Dbc.TranslatableString

  use Ecto.Schema

  @primary_key {:id, :id, []}
  embedded_schema do
    field(:reputation_id, :integer)

    embeds_one :reputation_race, ReputationRace, primary_key: false do
      field(:mask1, :integer)
      field(:mask2, :integer)
      field(:mask3, :integer)
      field(:mask4, :integer)
    end

    embeds_one :reputation_class, ReputationClass, primary_key: false do
      field(:mask1, :integer)
      field(:mask2, :integer)
      field(:mask3, :integer)
      field(:mask4, :integer)
    end

    embeds_one :reputation_base, ReputationBase, primary_key: false do
      field(:mask1, :integer)
      field(:mask2, :integer)
      field(:mask3, :integer)
      field(:mask4, :integer)
    end

    embeds_one :reputation_flag, ReputationFlag, primary_key: false do
      field(:mask1, :integer)
      field(:mask2, :integer)
      field(:mask3, :integer)
      field(:mask4, :integer)
    end

    embeds_one(:parent_faction, __MODULE__)

    embeds_one(:name, TranslatableString)
  end

  def player_human,
    do: %__MODULE__{
      id: 1,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "PLAYER, Human"}
    }

  def player_orc,
    do: %__MODULE__{
      id: 2,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "PLAYER, Orc"}
    }

  def player_dwarf,
    do: %__MODULE__{
      id: 3,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "PLAYER, Dwarf"}
    }

  def player_nightelf,
    do: %__MODULE__{
      id: 4,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "PLAYER, Night Elf"}
    }

  def player_undead,
    do: %__MODULE__{
      id: 5,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "PLAYER, Undead"}
    }

  def player_tauren,
    do: %__MODULE__{
      id: 6,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "PLAYER, Tauren"}
    }

  def creature,
    do: %__MODULE__{
      id: 7,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "Creature"}
    }

  def player_gnome,
    do: %__MODULE__{
      id: 8,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "PLAYER, Gnome"}
    }

  def player_troll,
    do: %__MODULE__{
      id: 9,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "PLAYER, Troll"}
    }

  def monster,
    do: %__MODULE__{
      id: 14,
      reputation_race: %ReputationRace{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_class: %ReputationClass{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_base: %ReputationBase{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      reputation_flag: %ReputationFlag{mask1: 0, mask2: 0, mask3: 0, mask4: 0},
      parent_faction: none(),
      name: %TranslatableString{en: "Monster"}
    }

  defp none, do: %__MODULE__{id: 0}
end
