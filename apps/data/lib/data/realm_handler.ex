defmodule Data.RealmHandler do
  @moduledoc """
  This module is responsible for handling the realm data.
  """
  alias Data.Repo
  alias Data.Schemas.Account
  alias Data.Schemas.Realm
  alias Ecto.Changeset

  import Ecto.Query

  @spec create_realm(params :: map()) :: {:ok, Realm.t()} | {:error, Changeset.t()}
  def create_realm(params) when is_map(params) do
    params
    |> Realm.changeset()
    |> Changeset.validate_required([:name, :address, :port])
    |> Repo.insert()
  end

  @spec allowed_realmlist(account :: Account.t()) :: list(Realm.t())
  def allowed_realmlist(%Account{level: level}) do
    Repo.all(from(r in Realm, where: r.allowed_account_level <= ^level))
  end

  @spec realmlist() :: list(Realm.t())
  def realmlist, do: Repo.all(Realm)

  @spec up(Realm.t()) :: {:ok, Realm.t()} | {:error, Changeset.t()}
  def up(realm = %Realm{}) do
    realm
    |> Realm.changeset(%{realmflags: 0x00})
    |> Changeset.validate_required([:realmflags])
    |> Repo.update()
  end

  @spec down(Realm.t()) :: {:ok, Realm.t()} | {:error, Changeset.t()}
  def down(realm = %Realm{}) do
    realm
    |> Realm.changeset(%{realmflags: 0x02})
    |> Changeset.validate_required([:realmflags])
    |> Repo.update()
  end
end
