defmodule Shared.Data.AccountHandler do
  @moduledoc """
  Module responsible for handling account related operations.
  """
  alias Ecto.Changeset
  alias Shared.Auth.SRP6
  alias Shared.Data.Repo
  alias Shared.Data.Schemas.Account

  require Logger

  @spec create_account(params :: map()) :: {:ok, Account.t()} | {:error, Changeset.t()}
  def create_account(params) do
    params
    |> Account.changeset()
    |> Changeset.validate_required([:username, :password])
    |> Changeset.update_change(:username, &String.upcase/1)
    |> then(fn changeset ->
      username = Changeset.get_change(changeset, :username)
      password = Changeset.get_change(changeset, :password)

      salt = SRP6.salt()
      derived_key = SRP6.derived_key(username, password, salt)
      verifier = SRP6.verifier(derived_key)

      changeset
      |> Changeset.put_change(:salt, salt)
      |> Changeset.put_change(:verifier, verifier)
    end)
    |> Repo.insert()
  end

  @spec get_by_username(username :: String.t()) :: Account.t() | nil
  def get_by_username(username) when is_binary(username) do
    Repo.get_by(Account, username: String.upcase(username))
  end

  def suspended?(%Account{banned_on: nil, ban_expires_at: nil}), do: false

  def suspended?(account = %Account{ban_expires_at: expiration_date}) do
    expiration_date
    |> then(fn expiration_date ->
      NaiveDateTime.diff(expiration_date, NaiveDateTime.utc_now()) > 0
    end)
    |> tap(fn
      false ->
        Logger.info(
          "Account with username #{account.username} is ready to be lifted from suspension."
        )

      true ->
        nil
    end)
  end

  def banned?(%Account{banned_on: nil, ban_expires_at: nil}), do: false
  def banned?(%Account{banned_on: _, ban_expires_at: nil}), do: true
  def banned?(%Account{banned_on: _, ban_expires_at: _}), do: false

  def lift_suspension(account = %Account{}) do
    account
    |> Changeset.change()
    |> Changeset.put_change(:banned_on, nil)
    |> Changeset.put_change(:ban_expires_at, nil)
    |> Repo.update()
    |> then(fn
      {:error, changeset} ->
        Logger.error("Could not lift suspension. Reason: #{inspect(changeset.errors)}.")
        {:error, changeset}

      {:ok, account} ->
        {:ok, account}
    end)
  end

  def set_session_key(username, session_key) do
    account = get_by_username(username)

    if is_nil(account) do
      Logger.warning("Account with username #{username} not found.")
      {:error, :account_not_found}
    else
      account
      |> Account.changeset(%{session_key: session_key})
      |> Changeset.validate_required([:session_key])
      |> Repo.update()
    end
  end
end
