class LeaderboardsController < ApplicationController
  allow_unauthenticated_access

  def show
    @rule = ScoringRule.current
    predictions = Prediction.includes(:fixture, :user).select { |prediction| prediction.fixture.result? }
    grouped_predictions = predictions.group_by(&:user)

    @rows = User.order(:username).map do |user|
      user_predictions = grouped_predictions[user] || []
      exact_scores = user_predictions.count(&:exact_score?)
      correct_goal_differences = user_predictions.count(&:correct_goal_difference?)
      correct_outcomes = user_predictions.count(&:correct_outcome?)

      {
        user: user,
        points: user_predictions.sum { |prediction| prediction.points(@rule) },
        predictions: user_predictions.count,
        exact_scores: exact_scores,
        correct_goal_differences: correct_goal_differences,
        correct_outcomes: correct_outcomes
      }
    end.sort_by { |row| [-row[:points], -row[:exact_scores], row[:user].username] }
  end
end
