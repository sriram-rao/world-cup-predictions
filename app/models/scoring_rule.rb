class ScoringRule < ApplicationRecord
  validates :outcome_points, :goal_difference_points, :exact_score_points,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.current
    first_or_create!
  end
end
