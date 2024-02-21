defmodule Data.Schemas.Realm do
  @moduledoc """
  The schema for the realmlist table.
  """
  alias Ecto.Changeset
  use Ecto.Schema

  @type t() :: %__MODULE__{
          name: String.t() | nil,
          address: String.t() | nil,
          port: non_neg_integer() | nil,
          icon: non_neg_integer() | nil,
          realmflags: non_neg_integer() | nil,
          timezone: non_neg_integer() | nil,
          allowed_account_level: :user | :moderator | :game_master | :administrator,
          population: float() | nil,
          realm_builds: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "realmlist" do
    field(:name, :string, default: "")
    field(:address, :string, default: "127.0.0.1")
    field(:port, :integer, default: 8085)
    field(:icon, :integer, default: 0)
    field(:realmflags, :integer, default: 0x2)
    field(:timezone, :integer, default: 0)

    field(:allowed_account_level, Ecto.Enum,
      values: [user: 0, moderator: 1, game_master: 2, administrator: 3],
      default: :user
    )

    field(:population, :float, default: 0.0)
    field(:realm_builds, :string, default: "")

    timestamps()
  end

  def changeset(mod \\ %__MODULE__{}, params) when is_map(params) do
    mod
    |> Changeset.cast(
      params,
      ~w(name address port icon realmflags timezone allowed_account_level population realm_builds)a
    )
    |> Changeset.unique_constraint(~w(name)a)
  end
end
