defmodule Shared.Data.Dbc.ChrClasses do
  @moduledoc """
  ChrClasses data.
  """
  alias Shared.Data.Dbc.TranslatableString

  use Ecto.Schema

  @primary_key {:id, :id, []}
  embedded_schema do
    field(:power_type, :integer)
    field(:spell_family, :integer)
    embeds_one(:name, TranslatableString)
  end

  def warrior,
    do: %__MODULE__{
      id: 1,
      power_type: 1,
      spell_family: 4,
      name: %TranslatableString{en: "Warrior"}
    }

  def paladin,
    do: %__MODULE__{
      id: 2,
      power_type: 0,
      spell_family: 10,
      name: %TranslatableString{en: "Paladin"}
    }

  def hunter,
    do: %__MODULE__{
      id: 3,
      power_type: 0,
      spell_family: 9,
      name: %TranslatableString{en: "Hunter"}
    }

  def rogue,
    do: %__MODULE__{id: 4, power_type: 3, spell_family: 8, name: %TranslatableString{en: "Rogue"}}

  def priest,
    do: %__MODULE__{
      id: 5,
      power_type: 0,
      spell_family: 6,
      name: %TranslatableString{en: "Priest"}
    }

  def shaman,
    do: %__MODULE__{
      id: 7,
      power_type: 0,
      spell_family: 11,
      name: %TranslatableString{en: "Shaman"}
    }

  def mage,
    do: %__MODULE__{id: 8, power_type: 0, spell_family: 3, name: %TranslatableString{en: "Mage"}}

  def warlock,
    do: %__MODULE__{
      id: 9,
      power_type: 0,
      spell_family: 5,
      name: %TranslatableString{en: "Warlock"}
    }

  def druid,
    do: %__MODULE__{
      id: 11,
      power_type: 0,
      spell_family: 7,
      name: %TranslatableString{en: "Druid"}
    }
end
