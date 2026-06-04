module FixturesHelper
  def fixture_stage(fixture)
    fixture.group_name.presence || fixture.round_number
  end

  def fixture_stage_path(fixture)
    fixture.group_name.present? ? group_path(fixture.group_name) : round_path(fixture.round_number)
  end

  def venue(location)
    location.gsub(/\s*stadium\s*/i, "").strip
  end
end
