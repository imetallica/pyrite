defmodule Shared.Data.Schemas.Character do
  @moduledoc """
  The schema for the characters table.
  """
  alias Ecto.Changeset
  alias Shared.Data.Dbc.ChrClasses
  alias Shared.Data.Dbc.ChrRaces
  alias Shared.Data.Schemas.Account
  alias Shared.Data.Schemas.Pet

  use Ecto.Schema

  schema "characters" do
    belongs_to(:account, Account)
    has_many(:pets, Pet)

    embeds_one :position, Position, primary_key: false do
      field(:x, :float, default: 0.0)
      field(:y, :float, default: 0.0)
      field(:z, :float, default: 0.0)
      field(:orientation, :float, default: 0.0)
    end

    field(:name, :string)

    field(:race, Ecto.Enum,
      values: [
        human: ChrRaces.human().id,
        nightelf: ChrRaces.nightelf().id,
        dwarf: ChrRaces.dwarf().id,
        gnome: ChrRaces.gnome().id,
        orc: ChrRaces.orc().id,
        troll: ChrRaces.troll().id,
        tauren: ChrRaces.tauren().id,
        forsaken: ChrRaces.scourge().id
      ]
    )

    field(:class, Ecto.Enum,
      values: [
        warrior: ChrClasses.warrior().id,
        rogue: ChrClasses.rogue().id,
        shaman: ChrClasses.shaman().id,
        paladin: ChrClasses.paladin().id,
        mage: ChrClasses.mage().id,
        priest: ChrClasses.priest().id,
        warlock: ChrClasses.warlock().id,
        hunter: ChrClasses.hunter().id,
        druid: ChrClasses.druid().id
      ]
    )

    field(:gender, Ecto.Enum, values: [male: 0, female: 1])
    field(:level, :integer, default: 0)
    field(:xp, :integer, default: 0)
    field(:money, :integer, default: 0)

    embeds_one :look, Look, primary_key: false do
      field(:skin, :integer, default: 0)
      field(:face, :integer, default: 0)
      field(:hair_style, :integer, default: 0)
      field(:hair_colour, :integer, default: 0)
      field(:facial_hair, :integer, default: 0)
      field(:rest_state, Ecto.Enum, values: [rested: 0x01, normal: 0x02, unknown: 0x04])
    end

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

    embeds_one :transport, Transport, primary_key: false do
      field(:x, :float, default: 0.0)
      field(:y, :float, default: 0.0)
      field(:z, :float, default: 0.0)
      field(:orientation, :float, default: 0.0)
      field(:identification, :integer, default: 0)
    end

    field(:extra_flags, :integer, default: 0)
    field(:stable_slots, :integer, default: 0)
    field(:at_login, :boolean, default: true)
    field(:death_expiration_time, :utc_datetime)

    embeds_one :honour, Honour do
      field(:highest_rank, Ecto.Enum, values: [none: 0], default: :none)
      field(:standing, Ecto.Enum, values: [none: 0], default: :none)
      field(:rating, :float, default: 0.0)
      field(:honourable_kills, :integer, default: 0)
      field(:dishonourable_kills, :integer, default: 0)
    end

    field(:watched_faction, :integer, default: 0)

    embeds_one :current_stats, CurrentStats, primary_key: false do
      field(:drunk, :integer, default: 0)
      field(:health, :integer, default: 0)
      # power 0
      field(:mana, :integer, default: 0)
      # power 1
      field(:rage, :integer, default: 0)
      # power 2
      field(:pet_focus, :integer, default: 0)
      # power 3
      field(:energy, :integer, default: 0)
      # power 4
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

  def enum_to_value(key, value) when is_atom(key) and is_atom(value) do
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
    |> Changeset.cast_embed(:look,
      with: &look_changeset/2,
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

  defp look_changeset(mod, params) when is_map(params) do
    mod
    |> Changeset.cast(
      params,
      ~w(skin face hair_style hair_colour facial_hair rest_state)a
    )
    |> Changeset.validate_required(~w(skin face hair_style hair_colour facial_hair rest_state)a)
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
