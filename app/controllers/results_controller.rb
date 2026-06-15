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

  def import
    date = Date.iso8601(params.fetch(:date))
    result = FootballDataResultImporter.new.import_day(date)
    Rails.cache.write("football_data_results/#{date.iso8601}", true, expires_in: 1.minute)
    Rails.logger.info("Football-data manual import cached for #{date}: expires_in=1.minute")

    message = "Updated #{result.updated.count}. Skipped #{result.skipped.count}. Unmatched #{result.unmatched.count}."
    message += " #{result.updated.join("; ")}" if result.updated.any?
    redirect_to root_path(date: date.iso8601), notice: message
  rescue KeyError
    redirect_to root_path(date: params[:date]), alert: "API_KEY missing. Add it to Render web service env vars."
  rescue => error
    Rails.logger.warn("Football-data manual import failed: #{error.class}: #{error.message}")
    redirect_to root_path(date: params[:date]), alert: "Result import failed: #{error.message}"
  end

  private
    def require_admin
      redirect_to root_path, alert: "Admins only." unless admin_mode?
    end

    def result_params
      params.require(:fixture).permit(:home_score, :away_score)
    end

    def fixture_day_path(fixture)
      root_path(date: fixture.match_date.in_time_zone(PACIFIC_TIME_ZONE).to_date.iso8601)
    end
end
