namespace :football_data do
  desc "Update fixture results from football-data.org. Usage: DATE=2026-06-14 API_KEY=... bin/rails football_data:update_results"
  task update_results: :environment do
    date = ENV.fetch("DATE", Time.zone.today.iso8601)
    result = FootballDataResultImporter.new.import_day(date)

    puts "Updated #{result.updated.count} fixtures"
    result.updated.each { |line| puts "  #{line}" }

    if result.skipped.any?
      puts "Skipped #{result.skipped.count} matches"
      result.skipped.each { |line| puts "  #{line}" }
    end

    if result.unmatched.any?
      puts "Unmatched #{result.unmatched.count} matches"
      result.unmatched.each { |line| puts "  #{line}" }
    end
  end
end
