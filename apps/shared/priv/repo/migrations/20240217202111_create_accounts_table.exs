defmodule Shared.Data.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:username, :string, null: false)
      add(:level, :integer, null: false, default: 0)
      add(:email, :string)
      add(:salt, :binary)
      add(:verifier, :binary)
      add(:session_key, :binary)
      add(:banned_on, :naive_datetime)
      add(:ban_expires_at, :naive_datetime)

      timestamps()
    end

    create(unique_index(:accounts, [:username]))
    create(index(:accounts, [:email]))
  end
end
