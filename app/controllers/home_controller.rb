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

      refresh_results_if_needed(@fixture_date) if @fixture_date == today

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

  private
    def refresh_results_if_needed(date)
      unless ENV["API_KEY"].present? || ENV["FOOTBALL_DATA_API_TOKEN"].present?
        Rails.logger.info("Football-data auto import skipped for #{date}: missing API key")
        return
      end

      cache_key = "football_data_results/#{date.iso8601}"
      if Rails.cache.read(cache_key)
        Rails.logger.info("Football-data auto import skipped for #{date}: cache hit")
        return
      end

      Rails.logger.info("Football-data auto import started for #{date}")
      result = FootballDataResultImporter.new.import_day(date)
      Rails.logger.info("Football-data auto import finished for #{date}: updated=#{result.updated.count} skipped=#{result.skipped.count} unmatched=#{result.unmatched.count}")
      Rails.logger.info("Football-data auto import skipped for #{date}: #{result.skipped.join("; ")}") if result.skipped.any?
      Rails.logger.info("Football-data auto import unmatched for #{date}: #{result.unmatched.join("; ")}") if result.unmatched.any?
      Rails.cache.write(cache_key, true, expires_in: 1.minute)
      Rails.logger.info("Football-data auto import cached for #{date}: expires_in=1.minute")
    rescue => error
      Rails.logger.warn("Football-data auto import failed for #{date}: #{error.class}: #{error.message}")
      Rails.cache.write(cache_key, true, expires_in: 15.minutes)
      Rails.logger.info("Football-data auto import failure cached for #{date}: expires_in=15.minutes")
    end
end
