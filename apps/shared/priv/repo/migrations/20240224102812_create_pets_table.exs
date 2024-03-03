defmodule Shared.Data.Repo.Migrations.CreatePetsTable do
  use Ecto.Migration

  def change do
    create table :pets do
      add :entry, :integer, null: false, default: 0
      add :character_id, references(:characters), null: false
      add :model_identifier, :integer, null: false, default: 0
      add :created_by_spell, :integer, null: false, default: 0
      add :pet_type, :integer, null: false, default: 0
      add :level, :integer, null: false, default: 1
      add :experience, :integer, null: false, default: 0
      add :react_state, :integer, null: false, default: 0
      add :loyalty_points, :integer, null: false, default: 0
      add :loyalty, :integer, null: false, default: 0
      add :training_points, :integer, null: false, default: 0
      add :name, :string, null: false, default: "Pet"
      add :slot, :integer, null: false, default: 0
      add :current_health, :integer, null: false, default: 1
      add :current_mana, :integer, null: false, default: 0
      add :current_hapiness, :integer, null: false, default: 0
      add :save_time, :integer, null: false, default: 0
      add :reset_talents_cost, :integer, null: false, default: 0
      add :amount_of_talets_reseted, :integer, null: false, default: 0
      add :action_bar_data, :text # Should it be {:array, :integer}?
      add :teach_spell_data, {:array, :integer}, null: false, default: []

      timestamps()
    end

    create index :pets, [:character_id]
    create constraint :pets, :max_slots, check: "slot <= 3"
  end
end
