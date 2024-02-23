defmodule Shared.Data.Repo.Migrations.CreateRealmListTable do
  use Ecto.Migration

  def change do
    create table(:realmlist) do
      add(:name, :string, null: false, default: "")
      add(:address, :string, null: false, default: "127.0.0.1")
      add(:port, :integer, null: false, default: 8085)
      add(:icon, :integer, null: false, default: 0)
      add(:realmflags, :integer, null: false, default: 2)
      add(:timezone, :integer, null: false, default: 0)
      add(:allowed_account_level, :integer, null: false, default: 0)
      add(:population, :float, null: false, default: 0.0)
      add(:realm_builds, :string, null: false, default: "")

      timestamps()
    end

    create(unique_index(:realmlist, [:name]))
  end
end
