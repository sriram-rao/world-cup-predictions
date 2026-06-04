class RoundsController < ApplicationController
  allow_unauthenticated_access

  def show
    @round_number = params[:round_number]
    @fixtures = Fixture.where(round_number: @round_number).order(:group_name, :match_date, :match_number)
    @grouped = @fixtures.any?(&:group_name?)
    @groups = @grouped ? @fixtures.group_by(&:group_name) : { @round_number => @fixtures }
  end
end
