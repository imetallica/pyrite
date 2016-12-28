defmodule Commons.Models.Account do
  use Ecto.Schema
  alias Commons.Repo
  require Logger
  import Ecto.Changeset
  alias Commons.{SRP, Repo, Models.Account}

  @type username :: String.t
  @type password :: String.t
  @type email :: String.t
  @type ban_type :: :permanent | :temporary
  @type ban_status :: :banned | :suspended | :not_banned
  @type expire_datetime :: %Ecto.DateTime{}
  @type session_key :: binary

  schema "accounts" do
    field :username,  :string
    field :salt,      :binary
    field :verifier,  :binary
    field :email,     :string
    field :banned_on, Ecto.DateTime
    field :banned_ex, Ecto.DateTime
    field :session_key, :binary

    field :password, :string, virtual: true

    timestamps
  end
  
  defp create_account_changeset(account, params \\ :empty) do
    account
    |> cast(params, ~w(username email password), ~w())
    |> resolve_srp()
    |> unique_constraint(:username)
  end

  defp ban_account_changeset(account, params \\ :empty) do
    account
    |> cast(params, ~w(banned_on banned_ex), ~w())
    |> normalize_username()
  end

  defp unban_account_changeset(account, _params \\ :empty) do
    account |> change(%{banned_on: :nil, banned_ex: :nil})
  end

  defp set_session_key_changeset(account, params \\ :empty) do
    account
    |> cast(params, ~w(session_key), ~w())
  end

  def normalize_username_param(username), do: SRP.normalize_string(username)

  defp normalize_username(changeset) do
    caps_username = (get_field(changeset, :username) |> SRP.normalize_string())
    changeset
    |> change(%{username: caps_username})
    |> apply_changes()
  end

  defp resolve_srp(changeset) do
    Logger.debug "Resolving SRP"
    username = get_change(changeset, :username)
    password = get_change(changeset, :password)
    IO.inspect "#{username}, #{password}"
    caps_username = SRP.normalize_string(username)
    salt = SRP.gen_salt
    gen = SRP.get_generator
    prime = SRP.get_prime
    d_key = SRP.get_derived_key(username, password, salt)
    ver = SRP.get_verifier(gen, prime, d_key)

    changeset |> change(%{salt: salt, verifier: ver, username: caps_username})
  end

  @spec create!(username, password, email) :: %Account{} | no_return
  @doc """
  Creates an account. If it succedes, it will return the model. If it fails,
  it will raise an error.
  """
  def create!(username, password, email) do
    %Account{}
    |> create_account_changeset(%{username: username, password: password, email: email})
    |> Repo.insert!
  end


  @spec get_by_username(username) :: %Account{} | :nil | no_return
  @doc """
  Queries the `accounts` table for the `username`.

  Returns `:nil` if no result was found.
  """
  def get_by_username(username) do
    Repo.get_by(Account, username: normalize_username_param(username))
  end


  @spec get_by_username!(username) :: %Account{} | no_return
  @doc """
  Similar to `get_by_username/1`, but raises if no result was found.
  """
  def get_by_username!(username) do
    Repo.get_by!(Account, username: Account.normalize_username_param(username))
  end
  
  @spec banned?(%Account{}) :: ban_status
  @doc """
  Checks if account is banned or suspended. Cleans up in case ban expired.

  In case a problem occurs on updating, it will flag the account as a suspended.
  """
  def banned?(account) do
    Logger.debug("Checking if #{Kernel.inspect(account.username)} is banned")
    if account.banned_on != :nil and 
       account.banned_ex != :nil do
      case Ecto.DateTime.compare(account.banned_on, account.banned_ex) do
        :eq -> :banned
        _ -> case Ecto.DateTime.compare(account.banned_ex, Ecto.DateTime.utc) do
          :lt ->
            Logger.info("Suspension on account #{account.username} has expired.")
            case Repo.update(unban_account_changeset(account)) do
              {:ok, _up} -> :not_banned
              {:error, _not_up} -> :suspended
            end
          _ -> :suspended
        end
      end
    else :not_banned
    end
  end

  @spec ban!(username, ban_type, expire_datetime) :: %Account{} | no_return
  @doc """
  Bans an `Account` depending on the type of the ban. Returns the banned account.

  The available types of ban are: `:permanent`, `:temporary`. If `:temporary`
  was chosen, you need to provide a date for unbanning, in the following
  format: `YYYY-MM-DD HH:MM:SS`.

  It will raise an error if the operation fails.
  """
  def ban!(username, ban_type, expire_datetime \\ :nil) do
    case ban_type do
      :permanent ->
        now = Ecto.DateTime.utc()
        Account
        |> Repo.get_by!(username: normalize_username_param(username))
        |> ban_account_changeset(%{banned_on: now, banned_ex: now})
        |> Repo.update!
      :temporary ->
        now = Ecto.DateTime.utc()
        exp = Ecto.DateTime.cast!(expire_datetime)

        Account
        |> Repo.get_by!(username: normalize_username_param(username))
        |> ban_account_changeset(%{banned_on: now, banned_ex: exp})
        |> Repo.update!
    end
  end

  @spec unban!(username) :: %Account{} | no_return
  @doc """
  Unbans the account. It will raise an error if the operation fails.
  """
  def unban!(username) do
    Repo.get_by!(Account, username: normalize_username_param(username))
    |> unban_account_changeset
    |> Repo.update!
  end

  @spec set_session_key(username, session_key) :: {:ok, %Account{}} | {:error, %Account{}} | :nil | no_return
  @doc """
  Sets the session key that will be used by the game server to validade client credentials.
  """
  def set_session_key(username, session_key) do
    case Repo.get_by(Account, username: normalize_username_param(username)) do
      :nil -> :nil
      account ->
        account |> set_session_key_changeset(%{session_key: session_key}) |> Repo.update
    end
  end
  
end