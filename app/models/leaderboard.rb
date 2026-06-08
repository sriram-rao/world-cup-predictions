class Leaderboard < ApplicationRecord
  STANDARD_SLUG = "standard"
  VAR_ROBBED_ME_SLUG = "var-robbed-me"

  OUTCOME_RULES = %w[exact_outcome exact_outcome_or_score_within_one_goal].freeze
  GOAL_DIFFERENCE_RULES = %w[exact_goal_difference goal_difference_within_one].freeze
  EXACT_SCORE_RULES = %w[exact_score score_within_one_goal].freeze

  validates :slug, :name, :description, presence: true
  validates :slug, uniqueness: true
  validates :outcome_rule, inclusion: { in: OUTCOME_RULES }
  validates :goal_difference_rule, inclusion: { in: GOAL_DIFFERENCE_RULES }
  validates :exact_score_rule, inclusion: { in: EXACT_SCORE_RULES }
  validates :outcome_points, :goal_difference_points, :exact_score_points,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true).order(:sort_order, :name) }

  def self.standard
    find_or_create_by!(slug: STANDARD_SLUG) do |leaderboard|
      leaderboard.name = "Leaderboard"
      leaderboard.description = "Outcome: 1 · Goal Difference: 2 · Score: 2"
      leaderboard.sort_order = 1
      leaderboard.outcome_points = 1
      leaderboard.goal_difference_points = 2
      leaderboard.exact_score_points = 2
      leaderboard.outcome_description = "Predicted outcome matches actual result.\nExample actual 2-1: points pick 1-0; no points pick 1-1."
      leaderboard.goal_difference_description = "Predicted signed goal difference matches exactly.\nExample actual 3-1 (+2): points pick 2-0 (+2); no points pick 1-3 (-2)."
      leaderboard.exact_score_description = "Predicted exact score.\nExample actual 2-2: points pick 2-2; no points pick 1-1."
      leaderboard.outcome_rule = "exact_outcome"
      leaderboard.goal_difference_rule = "exact_goal_difference"
      leaderboard.exact_score_rule = "exact_score"
    end
  end

  def self.var_robbed_me
    find_or_create_by!(slug: VAR_ROBBED_ME_SLUG) do |leaderboard|
      leaderboard.name = "VAR Robbed Me"
      leaderboard.description = "Close calls count: outcome, goal difference, and score points can still apply when you are only one goal away."
      leaderboard.sort_order = 2
      leaderboard.outcome_points = 1
      leaderboard.goal_difference_points = 2
      leaderboard.exact_score_points = 2
      leaderboard.outcome_description = "Predicted outcome matches actual result, or the scoreline is off by no more than 1 total goal.\nExample actual 3-3: points pick 2-3; no points pick 1-3."
      leaderboard.goal_difference_description = "Predicted signed goal difference is within 1.\nExample actual 3-1 (+2): points pick 2-1 (+1); no points pick 1-3 (-2)."
      leaderboard.exact_score_description = "Predicted scoreline is off by no more than 1 total goal.\nExample actual 3-2: points pick 3-3; no points pick 2-3."
      leaderboard.outcome_rule = "exact_outcome_or_score_within_one_goal"
      leaderboard.goal_difference_rule = "goal_difference_within_one"
      leaderboard.exact_score_rule = "score_within_one_goal"
    end
  end

  def outcome_correct?(prediction)
    case outcome_rule
    when "exact_outcome" then prediction.correct_outcome?
    when "exact_outcome_or_score_within_one_goal" then prediction.correct_outcome? || prediction.score_within_one_goal?
    end
  end

  def goal_difference_correct?(prediction)
    case goal_difference_rule
    when "exact_goal_difference" then prediction.correct_goal_difference?
    when "goal_difference_within_one" then prediction.goal_difference_within_one?
    end
  end

  def exact_score_correct?(prediction)
    case exact_score_rule
    when "exact_score" then prediction.exact_score?
    when "score_within_one_goal" then prediction.score_within_one_goal?
    end
  end

  def points_for(prediction)
    points = 0
    points += outcome_points if outcome_correct?(prediction)
    points += goal_difference_points if goal_difference_correct?(prediction)
    points += exact_score_points if exact_score_correct?(prediction)
    points
  end
end
