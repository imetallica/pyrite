defmodule Commons.Repo.Migrations.AddUserAccount do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :id,          :integer, primary_key: true # Workaround for mnesia adapter
      add :username,    :string
      add :salt,        :binary
      add :verifier,    :binary
      add :email,       :string
      add :banned_on,   :utc_datetime
      add :banned_ex,   :utc_datetime
      add :session_key, :binary

      timestamps()
    end

    create index(:accounts, [:username])
  end
end
