require "net/http"
require "json"

class FootballDataResultImporter
  API_URL = "https://api.football-data.org/v4/competitions/2000/matches/"
  PACIFIC_TIME_ZONE = "Pacific Time (US & Canada)"
  SEASON = 2026

  Result = Data.define(:updated, :skipped, :unmatched)

  def initialize(token: ENV.fetch("API_KEY") { ENV.fetch("FOOTBALL_DATA_API_TOKEN") })
    @token = token
    @pacific_time = ActiveSupport::TimeZone[PACIFIC_TIME_ZONE]
  end

  def import_day(date)
    date = Date.iso8601(date.to_s)
    Rails.logger.info("Football-data import_day date=#{date}")
    matches = fetch_matches(date)
    fixtures = fixtures_for(date)
    Rails.logger.info("Football-data import_day loaded matches=#{matches.count} fixtures=#{fixtures.count} date=#{date}")

    updated = []
    skipped = []
    unmatched = []

    matches.each do |match|
      next unless api_match_date(match) == date
      next skipped << skip(match, "not finished") unless match.fetch("status") == "FINISHED"

      score = match.fetch("score")
      full_time = score["fullTime"] || {}
      home_score = full_time["home"]
      away_score = full_time["away"]
      next skipped << skip(match, "missing score") if home_score.nil? || away_score.nil?

      duration = score["duration"] || "REGULAR"
      regular_time = score["regularTime"] || {}
      penalties = score["penalties"] || {}

      fixture = find_fixture(fixtures, match)
      unless fixture
        unmatched << match_label(match)
        next
      end

      fixture.update!(
        home_score: home_score,
        away_score: away_score,
        regular_home_score: duration == "REGULAR" ? nil : regular_time["home"],
        regular_away_score: duration == "REGULAR" ? nil : regular_time["away"],
        penalty_home_score: duration == "PENALTY_SHOOTOUT" ? penalties["home"] : nil,
        penalty_away_score: duration == "PENALTY_SHOOTOUT" ? penalties["away"] : nil,
        duration: duration
      )
      Rails.logger.info("Football-data updated fixture_id=#{fixture.id} duration=#{duration} #{fixture.home_team} #{home_score}-#{away_score} #{fixture.away_team}")
      updated << "#{fixture.home_team} #{home_score}-#{away_score} #{fixture.away_team}"
    end

    Result.new(updated:, skipped:, unmatched:)
  end

  private
    attr_reader :token, :pacific_time

    def fetch_matches(date)
      # Football-data filters by UTC date. Fetch adjacent UTC day too, then filter by PT app date.
      uri = URI(API_URL)
      uri.query = URI.encode_www_form(
        season: SEASON,
        dateFrom: date.iso8601,
        dateTo: (date + 1.day).iso8601
      )

      request = Net::HTTP::Get.new(uri)
      request["X-Auth-Token"] = token

      Rails.logger.info("Football-data fetch #{uri}")
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
      Rails.logger.info("Football-data response code=#{response.code}")
      raise "football-data API error #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body).fetch("matches")
    end

    def fixtures_for(date)
      start_time = pacific_time.local(date.year, date.month, date.day).utc
      end_time = start_time + 1.day
      Fixture.where(match_date: start_time...end_time).to_a
    end

    def find_fixture(fixtures, match)
      home = CountryLookup.from_football_data(match.dig("homeTeam", "name"))&.normalized_name || Country.normalize(match.dig("homeTeam", "name"))
      away = CountryLookup.from_football_data(match.dig("awayTeam", "name"))&.normalized_name || Country.normalize(match.dig("awayTeam", "name"))

      fixtures.find do |fixture|
        Country.normalize(fixture.home_team) == home && Country.normalize(fixture.away_team) == away
      end
    end

    def api_match_date(match)
      Time.iso8601(match.fetch("utcDate")).in_time_zone(pacific_time).to_date
    end

    def skip(match, reason)
      "#{match_label(match)} (#{reason})"
    end

    def match_label(match)
      "#{match.dig("homeTeam", "name")} v #{match.dig("awayTeam", "name")}"
    end
end
