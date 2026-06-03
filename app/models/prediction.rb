class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :fixture

  validates :home_score, :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
