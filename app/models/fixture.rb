class Fixture < ApplicationRecord
  has_many :predictions, dependent: :destroy
end
