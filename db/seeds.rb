require "csv"

fixtures_path = Rails.root.join("db/data/fixtures.csv")
pacific_time = ActiveSupport::TimeZone["Pacific Time (US & Canada)"]

ScoringRule.current

fixtures_imported = 0

CSV.foreach(fixtures_path, headers: true) do |row|
  fixture = Fixture.find_or_initialize_by(match_number: row.fetch("Match Number").to_i)
  fixture.assign_attributes(
    round_number: row.fetch("Round Number"),
    match_date: pacific_time.strptime(row.fetch("Date"), "%d/%m/%Y %H:%M"),
    location: row.fetch("Location"),
    home_team: row.fetch("Home Team"),
    away_team: row.fetch("Away Team"),
    group_name: row["Group"].presence
  )
  fixture.save!
  fixtures_imported += 1
end

puts "Imported #{fixtures_imported} fixtures"
