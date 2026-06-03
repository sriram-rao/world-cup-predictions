class CreatePredictions < ActiveRecord::Migration[8.1]
  def change
    create_table :predictions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :user_id, null: false
      t.uuid :fixture_id, null: false
      t.integer :home_score, null: false
      t.integer :away_score, null: false
    end

    add_foreign_key :predictions, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :predictions, :fixtures, on_delete: :cascade

    add_index :predictions, [:user_id, :fixture_id], unique: true

    add_check_constraint :predictions, "home_score >= 0", name: "predictions_home_score_non_negative"
    add_check_constraint :predictions, "away_score >= 0", name: "predictions_away_score_non_negative"
  end
end
