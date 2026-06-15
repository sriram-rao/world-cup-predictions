class PredictionsController < ApplicationController
  PACIFIC_TIME_ZONE = "Pacific Time (US & Canada)"

  def create
    save_prediction
  end

  def update
    save_prediction
  end

  private
    def save_prediction
      fixture = Fixture.find(params[:fixture_id])

      if fixture.locked?
        respond_to do |format|
          format.html { redirect_back fallback_location: fixture_day_path(fixture), alert: "Predictions are locked for that match." }
          format.json { render json: { error: "Predictions are locked for that match." }, status: :unprocessable_content }
        end
        return
      end

      prediction = Current.user.predictions.find_or_initialize_by(fixture: fixture)

      if prediction.update(prediction_params)
        respond_to do |format|
          format.html { redirect_back fallback_location: fixture_day_path(fixture), notice: "Prediction saved." }
          format.json { render json: { status: "saved" } }
        end
      else
        respond_to do |format|
          format.html { redirect_back fallback_location: fixture_day_path(fixture), alert: prediction.errors.full_messages.to_sentence }
          format.json { render json: { error: prediction.errors.full_messages.to_sentence }, status: :unprocessable_content }
        end
      end
    end

    def prediction_params
      params.require(:prediction).permit(:home_score, :away_score, :penalty_winner)
    end

    def fixture_day_path(fixture)
      root_path(date: fixture.match_date.in_time_zone(PACIFIC_TIME_ZONE).to_date.iso8601)
    end
end
