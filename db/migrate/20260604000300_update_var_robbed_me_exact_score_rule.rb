class UpdateVarRobbedMeExactScoreRule < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE leaderboards
      SET exact_score_rule = 'score_within_one_goal',
          exact_score_description = 'Predicted scoreline is off target by no more than 1 total goal.',
          updated_at = CURRENT_TIMESTAMP
      WHERE slug = 'var-robbed-me'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE leaderboards
      SET exact_score_rule = 'goal_difference_within_one',
          exact_score_description = 'Predicted scoreline is off target by no more than 1 goal of goal difference.',
          updated_at = CURRENT_TIMESTAMP
      WHERE slug = 'var-robbed-me'
    SQL
  end
end
