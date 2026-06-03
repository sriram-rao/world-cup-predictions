class ResultsController < ApplicationController
  PACIFIC_TIME_ZONE = "Pacific Time (US & Canada)"

  before_action :require_admin

  def update
    fixture = Fixture.find(params[:fixture_id])

    if fixture.update(result_params)
      redirect_back fallback_location: fixture_day_path(fixture), notice: "Result saved."
    else
      redirect_back fallback_location: fixture_day_path(fixture), alert: fixture.errors.full_messages.to_sentence
    end
  end

  private
    def require_admin
      redirect_to root_path, alert: "Admins only." unless Current.user&.admin?
    end

    def result_params
      params.require(:fixture).permit(:home_score, :away_score)
    end

    def fixture_day_path(fixture)
      root_path(date: fixture.match_date.in_time_zone(PACIFIC_TIME_ZONE).to_date.iso8601)
    end
end
