class LeaderboardsController < ApplicationController
  allow_unauthenticated_access

  def show
    @leaderboard = leaderboard_from_params
    @leaderboards = available_leaderboards
    @rules_path = rules_path_for(@leaderboard)
    @rows = leaderboard_rows(@leaderboard)
  end

  def var_robbed_me
    @leaderboard = Leaderboard.var_robbed_me
    @leaderboards = available_leaderboards
    @rules_path = rules_path_for(@leaderboard)
    @rows = leaderboard_rows(@leaderboard)
    render :show
  end

  private
    def leaderboard_from_params
      return Leaderboard.find_by!(slug: params[:slug]) if params[:slug].present?

      Leaderboard.standard
    end

    def available_leaderboards
      Leaderboard.standard
      Leaderboard.var_robbed_me
      Leaderboard.active
    end

    def leaderboard_rows(leaderboard)
      predictions = Prediction.includes(:fixture, :user).select { |prediction| prediction.fixture.result? }
      grouped_predictions = predictions.group_by(&:user)

      User.order(:username).map do |user|
        user_predictions = grouped_predictions[user] || []
        goal_differences = user_predictions.count { |prediction| leaderboard.goal_difference_correct?(prediction) }
        scorelines = user_predictions.count { |prediction| leaderboard.exact_score_correct?(prediction) }
        correct_outcomes = user_predictions.count { |prediction| leaderboard.outcome_correct?(prediction) }

        {
          user: user,
          points: user_predictions.sum { |prediction| leaderboard.points_for(prediction) },
          predictions: user_predictions.count,
          scorelines: scorelines,
          goal_differences: goal_differences,
          correct_outcomes: correct_outcomes
        }
      end.sort_by { |row| [-row[:points], -row[:scorelines], row[:user].username] }
    end

    def rules_path_for(leaderboard)
      leaderboard.slug == Leaderboard::STANDARD_SLUG ? scoring_rules_path : var_robbed_me_scoring_rules_path
    end
end
