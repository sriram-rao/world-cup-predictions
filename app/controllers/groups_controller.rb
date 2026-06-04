class GroupsController < ApplicationController
  allow_unauthenticated_access

  def show
    @group_name = params[:group_name]
    @group_names = Fixture.where.not(group_name: nil).distinct.order(:group_name).pluck(:group_name)
    @fixtures = Fixture.where(group_name: @group_name).order(:round_number, :match_date, :match_number)
    @standings = build_standings(@fixtures)
  end

  private
    def build_standings(fixtures)
      table = Hash.new do |hash, team|
        hash[team] = { team: team, played: 0, won: 0, drawn: 0, lost: 0, goals_for: 0, goals_against: 0, points: 0 }
      end

      fixtures.each do |fixture|
        table[fixture.home_team]
        table[fixture.away_team]
        next unless fixture.result?

        home = table[fixture.home_team]
        away = table[fixture.away_team]

        home[:played] += 1
        away[:played] += 1
        home[:goals_for] += fixture.home_score
        home[:goals_against] += fixture.away_score
        away[:goals_for] += fixture.away_score
        away[:goals_against] += fixture.home_score

        if fixture.home_score > fixture.away_score
          home[:won] += 1
          away[:lost] += 1
          home[:points] += 3
        elsif fixture.home_score < fixture.away_score
          away[:won] += 1
          home[:lost] += 1
          away[:points] += 3
        else
          home[:drawn] += 1
          away[:drawn] += 1
          home[:points] += 1
          away[:points] += 1
        end
      end

      table.values.sort_by { |row| [-row[:points], -(row[:goals_for] - row[:goals_against]), -row[:goals_for], row[:team]] }
    end
end
