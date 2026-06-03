class Fixture < ApplicationRecord
  has_many :predictions, dependent: :destroy

  validates :home_score, :away_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def result?
    home_score.present? && away_score.present?
  end

  def locked?
    match_date <= Time.current
  end
end
