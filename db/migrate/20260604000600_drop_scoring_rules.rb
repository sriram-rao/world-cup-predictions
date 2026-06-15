class DropScoringRules < ActiveRecord::Migration[8.1]
  def up
    drop_table :scoring_rules, if_exists: true
  end

  def down
    create_table :scoring_rules, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.integer :outcome_points, null: false, default: 1
      t.integer :goal_difference_points, null: false, default: 2
      t.integer :exact_score_points, null: false, default: 2
      t.string :variant, null: false, default: "standard"

      t.timestamps
    end

    add_index :scoring_rules, :variant, unique: true
    add_check_constraint :scoring_rules, "outcome_points >= 0", name: "scoring_rules_outcome_points_non_negative"
    add_check_constraint :scoring_rules, "goal_difference_points >= 0", name: "scoring_rules_goal_difference_points_non_negative"
    add_check_constraint :scoring_rules, "exact_score_points >= 0", name: "scoring_rules_exact_score_points_non_negative"
  end
end
