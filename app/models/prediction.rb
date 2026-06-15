class Prediction < ApplicationRecord
  NINETY_MINUTE_DRAW_POINTS = 1
  NINETY_MINUTE_SCORE_POINTS = 1
  PENALTY_WINNER_POINTS = 1

  belongs_to :user
  belongs_to :fixture

  before_validation :normalize_blank_penalty_winner

  validates :home_score, :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :penalty_winner, inclusion: { in: %w[home away] }, allow_nil: true

  def points(leaderboard = Leaderboard.standard)
    point_breakdown(leaderboard).sum { |part| part[:points] }
  end

  def point_breakdown(leaderboard = Leaderboard.standard)
    return [] unless fixture.result?

    parts = [
      { label: "Result", points: leaderboard.outcome_correct?(self) ? leaderboard.outcome_points : 0 },
      { label: "GD", points: leaderboard.goal_difference_correct?(self) ? leaderboard.goal_difference_points : 0 },
      { label: "Score", points: leaderboard.exact_score_correct?(self) ? leaderboard.exact_score_points : 0 }
    ]

    parts << { label: "90' Draw", points: NINETY_MINUTE_DRAW_POINTS } if ninety_minute_draw_bonus?
    parts << { label: "90' Score", points: NINETY_MINUTE_SCORE_POINTS } if ninety_minute_score_bonus?
    parts << { label: "Penalty shootout", points: PENALTY_WINNER_POINTS } if penalty_winner_bonus?
    parts
  end

  def draw?
    home_score == away_score
  end

  def predicted_winner
    return penalty_winner if draw?

    home_score > away_score ? "home" : "away"
  end

  def exact_score?
    home_score == fixture.home_score && away_score == fixture.away_score
  end

  def correct_outcome?
    home_outcome(home_score, away_score) == home_outcome(fixture.home_score, fixture.away_score)
  end

  def correct_result?
    correct_outcome? || correct_advancer?
  end

  def correct_advancer?
    fixture.knockout? && penalty_winner.present? && fixture.winner.present? && penalty_winner == fixture.winner
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

  def ninety_minute_draw_bonus?
    fixture.extra_time? && draw? && fixture.home_score != fixture.away_score && fixture.regular_home_score == fixture.regular_away_score
  end

  def ninety_minute_score_bonus?
    ninety_minute_draw_bonus? && home_score == fixture.regular_home_score && away_score == fixture.regular_away_score
  end

  def penalty_winner_bonus?
    fixture.penalties? && draw? && penalty_winner == fixture.penalty_winner
  end

  private
    def normalize_blank_penalty_winner
      self.penalty_winner = nil if penalty_winner.blank?
    end

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
