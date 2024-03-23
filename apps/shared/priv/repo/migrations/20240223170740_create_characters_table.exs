defmodule Shared.Data.Repo.Migrations.CreateCharactersTable do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :position, :jsonb, null: false
      add :name, :string, null: false, default: ""
      add :race, :integer, null: false, default: 0
      add :class, :integer, null: false, default: 0
      add :gender, :integer, null: false, default: 0
      add :level, :integer, null: false, default: 0
      add :xp, :integer, null: false, default: 0
      add :money, :integer, null: false, default: 0
      add :look, :jsonb, null: false
      add :map, :integer, null: false, default: 0
      add :zone, :integer, null: false, default: 0
      add :taximask, :text
      add :taxipath, :text
      add :online, :boolean, null: false, default: false
      add :cinematic, :boolean, null: false, default: false
      add :total_time, :integer, null: false, default: 0
      add :level_time, :integer, null: false, default: 0
      add :logout_time, :integer, null: false, default: 0
      add :logout_resting, :boolean, null: false, default: false
      add :rest_bonus, :float, null: false, default: 0
      add :reset_talents_cost, :integer, null: false, default: 0
      add :transport, :jsonb, null: false
      add :extra_flags, :integer, null: false, default: 0
      add :stable_slots, :integer, null: false, default: 0
      add :at_login, :boolean, null: false, default: false
      add :death_expiration_time, :utc_datetime
      add :honour, :jsonb, null: false
      add :watched_faction, :integer, null: false, default: 0
      add :current_stats, :jsonb, null: false
      add :explored_zones, {:array, :integer}, null: false, default: []
      # TODO: Explore possibility of this be a jsonb instead.
      add :equipment_cache, {:array, :integer}, null: false, default: []
      add :ammo_id, :integer, null: false, default: 0

      timestamps()
    end

    create unique_index(:characters, [:name])
    create index(:characters, [:online])
    create index(:characters, [:account_id])
    create constraint(:characters, :max_stable_slots, check: "stable_slots <= 2")
  end
end
