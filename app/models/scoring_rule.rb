class ScoringRule < ApplicationRecord
  STANDARD = "standard"
  VAR_ROBBED_ME = "var_robbed_me"

  validates :variant, presence: true, uniqueness: true
  validates :outcome_points, :goal_difference_points, :exact_score_points,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.current(variant = STANDARD)
    find_or_create_by!(variant: variant)
  end
end
