class HomeController < ApplicationController
  allow_unauthenticated_access

  PACIFIC_TIME_ZONE = "Pacific Time (US & Canada)"

  def index
    Time.use_zone(PACIFIC_TIME_ZONE) do
      today = Time.zone.today

      @fixture_date = if params[:date].present?
        Date.iso8601(params[:date])
      else
        next_fixture = Fixture.where("match_date >= ?", today.beginning_of_day).order(:match_date).first
        next_fixture&.match_date&.in_time_zone(PACIFIC_TIME_ZONE)&.to_date || today
      end

      @previous_date = @fixture_date - 1.day
      @next_date = @fixture_date + 1.day
      @fixtures = Fixture.where(match_date: @fixture_date.all_day).order(:match_date)
      @predictions_by_fixture_id = if authenticated?
        Current.user.predictions.where(fixture: @fixtures).index_by(&:fixture_id)
      else
        {}
      end
    rescue Date::Error
      redirect_to root_path
    end
  end
end
