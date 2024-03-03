defmodule Shared.Data.Schemas.Pet do
  @moduledoc """
  Character pet data.
  """
  alias Shared.Data.Schemas.Character
  alias Ecto.Changeset

  use Ecto.Schema

  schema "pets" do
    belongs_to(:character, Character)

    field(:entry, :integer, default: 0)
    field(:model_identifier, :integer, default: 0)
    field(:created_by_spell, :integer, default: 0)
    field(:pet_type, :integer, default: 0)
    field(:level, :integer, default: 1)
    field(:experience, :integer, default: 0)
    field(:react_state, :integer, default: 0)
    field(:loyalty_points, :integer, default: 0)
    field(:loyalty, :integer, default: 0)
    field(:training_points, :integer, default: 0)
    field(:name, :string, default: "Pet")
    field(:slot, :integer, default: 0)
    field(:current_health, :integer, default: 0)
    field(:current_mana, :integer, default: 0)
    field(:current_hapiness, :integer, default: 0)
    field(:save_time, :integer, default: 0)
    field(:reset_talents_cost, :integer, default: 0)
    field(:amount_of_talets_reseted, :integer, default: 0)
    field(:action_bar_data, :string)
    field(:teach_spell_data, {:array, :integer}, default: [])

    timestamps()
  end

  @params ~w(
    entry
    character_id
    model_identifier
    created_by_spell
    pet_type
    level
    experience
    react_state
    loyalty_points
    loyalty
    training_points
    name
    slot
    current_health
    current_mana
    current_hapiness
    save_time
    reset_talents_cost
    amount_of_talets_reseted
    action_bar_data
    teach_spell_data
  )a

  @required @params -- ~w(action_bar_data teach_spell_data)a

  def changeset(mod \\ %__MODULE__{}, params) when is_map(params) do
    mod
    |> Changeset.cast(params, @params)
    |> Changeset.validate_required(@required)
    |> Changeset.foreign_key_constraint(:character_id)
    |> Changeset.check_constraint(:slot, name: :max_slots)
  end
end
