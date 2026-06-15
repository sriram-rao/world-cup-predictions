class FixturesController < ApplicationController
  allow_unauthenticated_access

  def show
    @fixture = Fixture.find(params[:id])
    @rule = Leaderboard.standard
    @max_points = @rule.outcome_points + @rule.goal_difference_points + @rule.exact_score_points
    @predictions = @fixture.predictions
      .includes(:user)
      .sort_by { |p| [-p.points(@rule), p.user.username] }
    @user_prediction = authenticated? ? @predictions.find { |p| p.user == Current.user } : nil
    @back_date = @fixture.match_date.in_time_zone("Pacific Time (US & Canada)").to_date.iso8601
  end
end
