class CreateLeaderboards < ActiveRecord::Migration[8.1]
  def change
    create_table :leaderboards, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.integer :sort_order, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.integer :outcome_points, null: false, default: 1
      t.integer :goal_difference_points, null: false, default: 2
      t.integer :exact_score_points, null: false, default: 2

      t.text :outcome_description, null: false
      t.text :goal_difference_description, null: false
      t.text :exact_score_description, null: false

      t.string :goal_difference_rule, null: false, default: "exact_goal_difference"
      t.string :exact_score_rule, null: false, default: "exact_score"

      t.timestamps
    end

    add_index :leaderboards, :slug, unique: true
    add_check_constraint :leaderboards, "outcome_points >= 0", name: "leaderboards_outcome_points_non_negative"
    add_check_constraint :leaderboards, "goal_difference_points >= 0", name: "leaderboards_goal_difference_points_non_negative"
    add_check_constraint :leaderboards, "exact_score_points >= 0", name: "leaderboards_exact_score_points_non_negative"
  end
end
