class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :fixture

  validates :home_score, :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def points(leaderboard = Leaderboard.standard)
    point_breakdown(leaderboard).sum { |part| part[:points] }
  end

  def point_breakdown(leaderboard = Leaderboard.standard)
    return [] unless fixture.result?

    [
      { label: "Result", points: leaderboard.outcome_correct?(self) ? leaderboard.outcome_points : 0 },
      { label: "GD", points: leaderboard.goal_difference_correct?(self) ? leaderboard.goal_difference_points : 0 },
      { label: "Score", points: leaderboard.exact_score_correct?(self) ? leaderboard.exact_score_points : 0 }
    ]
  end

  def exact_score?
    home_score == fixture.home_score && away_score == fixture.away_score
  end

  def correct_outcome?
    home_outcome(home_score, away_score) == home_outcome(fixture.home_score, fixture.away_score)
  end

  def correct_goal_difference?
    predicted_goal_difference == actual_goal_difference
  end

  def goal_difference_within_one?
    (predicted_goal_difference - actual_goal_difference).abs <= 1
  end

  def score_within_one_goal?
    (home_score - fixture.home_score).abs + (away_score - fixture.away_score).abs <= 1
  end

  alias_method :var_robbed_scoreline?, :goal_difference_within_one?

  private
    def predicted_goal_difference
      home_score - away_score
    end

    def actual_goal_difference
      fixture.home_score - fixture.away_score
    end
    def home_outcome(home, away)
      home <=> away
    end
end
