defmodule Shared.Data.Schemas.Character do
  @moduledoc """
  The schema for the characters table.
  """
  alias Ecto.Changeset
  alias Shared.Data.Schemas.Account
  alias Shared.Data.Schemas.Pet

  use Ecto.Schema

  schema "characters" do
    belongs_to(:account, Account)
    has_many(:pets, Pet)

    embeds_one :position, Position do
      field(:x, :float, default: 0.0)
      field(:y, :float, default: 0.0)
      field(:z, :float, default: 0.0)
      field(:orientation, :float, default: 0.0)
    end

    field(:name, :string)

    # TODO: Check this values in chrraces.dbc.
    field(:race, Ecto.Enum,
      values: [
        human: 0,
        night_elf: 1,
        dwarf: 2,
        gnome: 3,
        orc: 4,
        troll: 5,
        tauren: 6,
        forsaken: 7
      ]
    )

    # TODO: Check this values in chrclasses.dbc.
    field(:class, Ecto.Enum,
      values: [
        warrior: 0,
        rogue: 1,
        shaman: 2,
        paladin: 3,
        mage: 4,
        priest: 5,
        warlock: 6,
        hunter: 7
      ]
    )

    field(:gender, Ecto.Enum, values: [male: 0, female: 1])
    field(:level, :integer, default: 0)
    field(:xp, :integer, default: 0)
    field(:money, :integer, default: 0)
    field(:player_bytes, :integer, default: 0)
    field(:player_bytes2, :integer, default: 0)

    field(:map, Ecto.Enum, values: [east: 0, west: 1])
    field(:zone, Ecto.Enum, values: [])

    field(:taximask, :string)
    field(:taxipath, :string)
    field(:online, :boolean, default: false)
    field(:cinematic, :boolean, default: false)
    field(:total_time, :integer, default: 0)
    field(:level_time, :integer, default: 0)
    field(:logout_time, :integer, default: 0)
    field(:logout_resting, :boolean, default: false)
    field(:rest_bonus, :float, default: 0.0)
    field(:reset_talents_cost, :integer, default: 0)

    embeds_one :transport, Transport do
      field(:x, :float, default: 0.0)
      field(:y, :float, default: 0.0)
      field(:z, :float, default: 0.0)
      field(:orientation, :float, default: 0.0)
      field(:identification, :integer, default: 0)
    end

    field(:extra_flags, :integer, default: 0)
    field(:stable_slots, :integer, default: 0)
    field(:at_login, :boolean, default: false)
    field(:death_expiration_time, :utc_datetime)

    embeds_one :honour, Honour do
      field(:highest_rank, Ecto.Enum, values: [none: 0], default: :none)
      field(:standing, Ecto.Enum, values: [none: 0], default: :none)
      field(:rating, :float, default: 0.0)
      field(:honourable_kills, :integer, default: 0)
      field(:dishonourable_kills, :integer, default: 0)
    end

    field(:watched_faction, :integer, default: 0)

    embeds_one :current_stats, CurrentStats do
      field(:drunk, :integer, default: 0)
      field(:health, :integer, default: 0)
      # power 1
      field(:mana, :integer, default: 0)
      # power 2
      field(:rage, :integer, default: 0)
      # power 3
      field(:pet_focus, :integer, default: 0)
      # power 4
      field(:energy, :integer, default: 0)
      # power 5
      field(:pet_happiness, :integer, default: 0)
    end

    field(:explored_zones, {:array, :integer}, default: [])
    field(:equipment_cache, {:array, :integer}, default: [])
    field(:ammo_id, :integer)

    timestamps()
  end

  @permitted ~w(
    account_id
    name
    race
    class
    gender
    level
    xp
    money
    player_bytes
    player_bytes2
    map
    zone
    taximask
    taxipath
    online
    cinematic
    total_time
    level_time
    logout_time
    logout_resting
    rest_bonus
    reset_talents_cost
    extra_flags
    stable_slots
    at_login
    death_expiration_time
    watched_faction
    explored_zones
    equipment_cache
    ammo_id
  )a

  @required @permitted -- ~w(taximask taxipath)a

  def map(key, value) when is_atom(key) and is_atom(value) do
    Keyword.get(Ecto.Enum.mappings(__MODULE__, key), value)
  end

  def changeset(mod \\ %__MODULE__{}, params) when is_map(params) do
    mod
    |> Changeset.cast(params, @permitted)
    |> Changeset.cast_embed(:position,
      with: &position_changeset/2,
      on_replace: :update,
      required: true
    )
    |> Changeset.cast_embed(:transport,
      with: &transport_changeset/2,
      on_replace: :update,
      required: true
    )
    |> Changeset.cast_embed(:honour,
      with: &honour_changeset/2,
      on_replace: :update,
      required: true
    )
    |> Changeset.cast_embed(:current_stats,
      with: &current_stats_changeset/2,
      on_replace: :update,
      required: true
    )
    |> Changeset.validate_required(@required)
    |> Changeset.unique_constraint([:name])
    |> Changeset.foreign_key_constraint(:account_id)
    |> Changeset.check_constraint(:stable_slots, name: :max_stable_slots)
  end

  defp position_changeset(mod, params) when is_map(params) do
    mod
    |> Changeset.cast(params, ~w(x y z orientation)a)
    |> Changeset.validate_required(~w(x y z orientation)a)
  end

  defp transport_changeset(mod, params) when is_map(params) do
    mod
    |> Changeset.cast(params, ~w(x y z orientation identification)a)
    |> Changeset.validate_required(~w(x y z orientation identification)a)
  end

  defp honour_changeset(mod, params) when is_map(params) do
    mod
    |> Changeset.cast(
      params,
      ~w(highest_rank standing rating honourable_kills dishonourable_kills)a
    )
    |> Changeset.validate_required(
      ~w(highest_rank standing rating honourable_kills dishonourable_kills)a
    )
  end

  defp current_stats_changeset(mod, params) when is_map(params) do
    mod
    |> Changeset.cast(
      params,
      ~w(drunk health mana rage pet_focus energy pet_happiness)a
    )
    |> Changeset.validate_required(~w(drunk health mana rage pet_focus energy pet_happiness)a)
  end
end
