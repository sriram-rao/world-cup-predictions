class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :fixture

  validates :home_score, :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def points(rule = ScoringRule.current)
    point_breakdown(rule).sum { |part| part[:points] }
  end

  def point_breakdown(rule = ScoringRule.current)
    return [] unless fixture.result?

    [
      { label: "Result", points: correct_outcome? ? rule.outcome_points : 0 },
      { label: "GD", points: correct_goal_difference? ? rule.goal_difference_points : 0 },
      { label: "Score", points: exact_score? ? rule.exact_score_points : 0 }
    ]
  end

  def exact_score?
    home_score == fixture.home_score && away_score == fixture.away_score
  end

  def correct_outcome?
    home_outcome(home_score, away_score) == home_outcome(fixture.home_score, fixture.away_score)
  end

  def correct_goal_difference?
    (home_score - away_score) == (fixture.home_score - fixture.away_score)
  end

  private
    def home_outcome(home, away)
      home <=> away
    end
end
