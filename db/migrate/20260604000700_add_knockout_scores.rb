class AddKnockoutScores < ActiveRecord::Migration[8.1]
  def change
    change_table :fixtures do |t|
      t.integer :regular_home_score
      t.integer :regular_away_score
      t.integer :penalty_home_score
      t.integer :penalty_away_score
      t.string :duration
    end

    add_check_constraint :fixtures, "regular_home_score >= 0", name: "fixtures_regular_home_score_non_negative"
    add_check_constraint :fixtures, "regular_away_score >= 0", name: "fixtures_regular_away_score_non_negative"
    add_check_constraint :fixtures, "penalty_home_score >= 0", name: "fixtures_penalty_home_score_non_negative"
    add_check_constraint :fixtures, "penalty_away_score >= 0", name: "fixtures_penalty_away_score_non_negative"

    add_column :predictions, :penalty_winner, :string
    add_check_constraint :predictions, "penalty_winner IN ('home', 'away')", name: "predictions_penalty_winner_valid"
  end
end
