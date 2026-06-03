class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :predictions, dependent: :destroy

  normalizes :username, with: ->(username) { username.strip.downcase }

  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_]{3,24}\z/, message: "must be 3-24 characters using letters, numbers, or underscores" }
end
