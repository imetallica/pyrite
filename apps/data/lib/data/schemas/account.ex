defmodule Data.Schemas.Account do
  @moduledoc """
  The schema for the accounts table.
  """
  use Ecto.Schema
  alias Ecto.Changeset

  @type t() :: %__MODULE__{
          id: integer() | nil,
          username: String.t() | nil,
          level: :user | :moderator | :game_master | :administrator,
          email: String.t() | nil,
          salt: binary() | nil,
          verifier: binary() | nil,
          session_key: binary() | nil,
          banned_on: NaiveDateTime.t() | nil,
          ban_expires_at: NaiveDateTime.t() | nil,
          password: String.t() | nil
        }

  schema "accounts" do
    field(:username, :string)

    field(:level, Ecto.Enum,
      values: [user: 0, moderator: 1, game_master: 2, administrator: 3],
      default: :user
    )

    field(:email, :string)
    field(:salt, :binary)
    field(:verifier, :binary)
    field(:session_key, :binary)
    field(:banned_on, :naive_datetime)
    field(:ban_expires_at, :naive_datetime)

    field(:password, :string, virtual: true)

    timestamps()
  end

  def changeset(mod \\ %__MODULE__{}, params) when is_map(params) do
    mod
    |> Changeset.cast(
      params,
      ~w(username password email salt verifier session_key banned_on ban_expires_at)a
    )
    |> Changeset.unique_constraint(~w(username)a)
  end
end
