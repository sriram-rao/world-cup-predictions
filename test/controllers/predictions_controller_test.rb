require "test_helper"

class PredictionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @fixture = Fixture.create!(
      match_number: 999,
      round_number: "1",
      match_date: 1.week.from_now,
      location: "Test Stadium",
      home_team: "Home",
      away_team: "Away"
    )
  end

  test "creates prediction" do
    sign_in_as @user

    assert_difference "Prediction.count", 1 do
      post fixture_prediction_path(@fixture), params: { prediction: { home_score: 1, away_score: 0 } }
    end

    prediction = @user.predictions.find_by!(fixture: @fixture)
    assert_equal 1, prediction.home_score
    assert_equal 0, prediction.away_score
  end

  test "updates existing prediction" do
    prediction = @user.predictions.create!(fixture: @fixture, home_score: 1, away_score: 0)
    sign_in_as @user

    assert_no_difference "Prediction.count" do
      patch fixture_prediction_path(@fixture), params: { prediction: { home_score: 2, away_score: 1 } }
    end

    prediction.reload
    assert_equal 2, prediction.home_score
    assert_equal 1, prediction.away_score
  end
end
