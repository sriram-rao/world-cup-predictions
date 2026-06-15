class Fixture < ApplicationRecord
  has_many :predictions, dependent: :destroy

  before_validation :normalize_blank_duration

  validates :home_score, :away_score, :regular_home_score, :regular_away_score, :penalty_home_score, :penalty_away_score,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :duration, inclusion: { in: %w[REGULAR EXTRA_TIME PENALTY_SHOOTOUT] }, allow_nil: true

  def result?
    home_score.present? && away_score.present?
  end

  def knockout?
    group_name.blank?
  end

  def extra_time?
    regular_home_score.present? && regular_away_score.present?
  end

  def penalties?
    penalty_home_score.present? && penalty_away_score.present?
  end

  def penalty_winner
    return unless penalties?

    penalty_home_score > penalty_away_score ? "home" : "away"
  end

  def winner
    return unless result?
    return penalty_winner if penalties?
    return "home" if home_score > away_score
    return "away" if away_score > home_score
  end

  def result_label
    return "v" unless result?

    label = "#{home_score}–#{away_score}"
    label += " AET" if extra_time?
    label
  end

  def result_details
    return [] unless result?

    [].tap do |details|
      details << "90': #{regular_home_score}–#{regular_away_score}" if extra_time?
      details << "Penalty shootout: #{penalty_home_score}–#{penalty_away_score}" if penalties?
    end
  end

  def locked?
    match_date <= Time.current
  end

  private
    def normalize_blank_duration
      self.duration = nil if duration.blank?
    end
end
