class CountryAlias < ApplicationRecord
  belongs_to :country

  before_validation :set_normalized_name

  validates :source, :name, :normalized_name, presence: true
  validates :normalized_name, uniqueness: { scope: :source }

  private
    def set_normalized_name
      self.normalized_name = Country.normalize(name)
    end
end
