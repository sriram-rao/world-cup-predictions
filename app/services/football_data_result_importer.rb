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
      duration = score["duration"] || "REGULAR"
      home_score, away_score = final_score(score, duration)
      next skipped << skip(match, "missing score") if home_score.nil? || away_score.nil?

      regular_home_score, regular_away_score = duration == "REGULAR" ? [nil, nil] : score_pair(score["regularTime"])
      penalty_home_score, penalty_away_score = duration == "PENALTY_SHOOTOUT" ? penalty_score(score, [home_score, away_score]) : [nil, nil]

      fixture = find_fixture(fixtures, match)
      unless fixture
        unmatched << match_label(match)
        next
      end

      fixture.update!(
        home_score: home_score,
        away_score: away_score,
        regular_home_score: regular_home_score,
        regular_away_score: regular_away_score,
        penalty_home_score: penalty_home_score,
        penalty_away_score: penalty_away_score,
        duration: duration
      )
      Rails.logger.info("Football-data updated fixture_id=#{fixture.id} duration=#{duration} #{fixture.home_team} #{home_score}-#{away_score} #{fixture.away_team} regular=#{regular_home_score.inspect}-#{regular_away_score.inspect} penalties=#{penalty_home_score.inspect}-#{penalty_away_score.inspect}")
      updated << "#{fixture.home_team} #{home_score}-#{away_score} #{fixture.away_team}"
    end

    Result.new(updated:, skipped:, unmatched:)
  end

  private
    attr_reader :token, :pacific_time

    def final_score(score, duration)
      full_time = score_pair(score["fullTime"])
      return full_time if duration == "REGULAR"

      regular_time = score_pair(score["regularTime"])
      extra_time = score_pair(score["extraTime"])
      return [regular_time[0] + extra_time[0], regular_time[1] + extra_time[1]] if regular_time && extra_time

      penalties = score_pair(score["penalties"])
      if duration == "PENALTY_SHOOTOUT" && full_time && penalties && full_time[0] >= penalties[0] && full_time[1] >= penalties[1]
        return [full_time[0] - penalties[0], full_time[1] - penalties[1]]
      end

      full_time
    end

    def penalty_score(score, final_score)
      full_time = score_pair(score["fullTime"])
      if full_time && final_score && full_time[0] >= final_score[0] && full_time[1] >= final_score[1]
        return [full_time[0] - final_score[0], full_time[1] - final_score[1]]
      end

      score_pair(score["penalties"])
    end

    def score_pair(node)
      return unless node

      home = node["home"]
      away = node["away"]
      return if home.nil? || away.nil?

      [home, away]
    end

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
