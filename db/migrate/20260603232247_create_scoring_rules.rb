class CreateScoringRules < ActiveRecord::Migration[8.1]
  def change
    create_table :scoring_rules, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.integer :outcome_points, null: false, default: 1
      t.integer :goal_difference_points, null: false, default: 2
      t.integer :exact_score_points, null: false, default: 2

      t.timestamps
    end

    add_check_constraint :scoring_rules, "outcome_points >= 0", name: "scoring_rules_outcome_points_non_negative"
    add_check_constraint :scoring_rules, "goal_difference_points >= 0", name: "scoring_rules_goal_difference_points_non_negative"
    add_check_constraint :scoring_rules, "exact_score_points >= 0", name: "scoring_rules_exact_score_points_non_negative"
  end
end
