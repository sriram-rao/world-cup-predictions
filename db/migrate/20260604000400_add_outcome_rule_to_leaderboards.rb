class AddOutcomeRuleToLeaderboards < ActiveRecord::Migration[8.1]
  def up
    add_column :leaderboards, :outcome_rule, :string, null: false, default: "exact_outcome"

    update_descriptions(
      "standard",
      "exact_outcome",
      "Predicted outcome matches actual result.\nExample actual 2-1: points pick 1-0; no points pick 1-1.",
      "Predicted signed goal difference matches exactly.\nExample actual 3-1 (+2): points pick 2-0 (+2); no points pick 1-3 (-2).",
      "Predicted exact score.\nExample actual 2-2: points pick 2-2; no points pick 1-1."
    )

    update_descriptions(
      "var-robbed-me",
      "exact_outcome_or_score_within_one_goal",
      "Predicted outcome matches actual result, or the scoreline is off by no more than 1 total goal.\nExample actual 3-3: points pick 2-3; no points pick 1-3.",
      "Predicted signed goal difference is within 1.\nExample actual 3-1 (+2): points pick 2-1 (+1); no points pick 1-3 (-2).",
      "Predicted scoreline is off by no more than 1 total goal.\nExample actual 3-2: points pick 3-3; no points pick 2-3."
    )
  end

  def down
    remove_column :leaderboards, :outcome_rule
  end

  private
    def update_descriptions(slug, outcome_rule, outcome, goal_difference, exact_score)
      execute <<~SQL
        UPDATE leaderboards
        SET outcome_rule = #{quote(outcome_rule)},
            outcome_description = #{quote(outcome)},
            goal_difference_description = #{quote(goal_difference)},
            exact_score_description = #{quote(exact_score)},
            updated_at = CURRENT_TIMESTAMP
        WHERE slug = #{quote(slug)}
      SQL
    end
end
