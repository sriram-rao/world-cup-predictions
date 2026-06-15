class Country < ApplicationRecord
  has_many :aliases, class_name: "CountryAlias", dependent: :destroy

  DEFAULTS = [
    ["Algeria", "🇩🇿"],
    ["Argentina", "🇦🇷"],
    ["Australia", "🇦🇺"],
    ["Austria", "🇦🇹"],
    ["Belgium", "🇧🇪"],
    ["Bosnia and Herzegovina", "🇧🇦"],
    ["Brazil", "🇧🇷"],
    ["Cabo Verde", "🇨🇻"],
    ["Canada", "🇨🇦"],
    ["Colombia", "🇨🇴"],
    ["Congo DR", "🇨🇩"],
    ["Croatia", "🇭🇷"],
    ["Curaçao", "🇨🇼"],
    ["Czechia", "🇨🇿"],
    ["Côte d'Ivoire", "🇨🇮"],
    ["Ecuador", "🇪🇨"],
    ["Egypt", "🇪🇬"],
    ["England", "🏴"],
    ["France", "🇫🇷"],
    ["Germany", "🇩🇪"],
    ["Ghana", "🇬🇭"],
    ["Haiti", "🇭🇹"],
    ["IR Iran", "🇮🇷"],
    ["Iraq", "🇮🇶"],
    ["Japan", "🇯🇵"],
    ["Jordan", "🇯🇴"],
    ["Korea Republic", "🇰🇷"],
    ["Mexico", "🇲🇽"],
    ["Morocco", "🇲🇦"],
    ["Netherlands", "🇳🇱"],
    ["New Zealand", "🇳🇿"],
    ["Norway", "🇳🇴"],
    ["Panama", "🇵🇦"],
    ["Paraguay", "🇵🇾"],
    ["Portugal", "🇵🇹"],
    ["Qatar", "🇶🇦"],
    ["Saudi Arabia", "🇸🇦"],
    ["Scotland", "🏴"],
    ["Senegal", "🇸🇳"],
    ["South Africa", "🇿🇦"],
    ["Spain", "🇪🇸"],
    ["Sweden", "🇸🇪"],
    ["Switzerland", "🇨🇭"],
    ["Tunisia", "🇹🇳"],
    ["Türkiye", "🇹🇷"],
    ["USA", "🇺🇸"],
    ["Uruguay", "🇺🇾"],
    ["Uzbekistan", "🇺🇿"]
  ].freeze

  FOOTBALL_DATA_ALIASES = {
    "Bosnia and Herzegovina" => "Bosnia-Herzegovina",
    "Cabo Verde" => ["Cape Verde", "Cape Verde Islands"],
    "Congo DR" => "DR Congo",
    "Côte d'Ivoire" => "Ivory Coast",
    "IR Iran" => "Iran",
    "Korea Republic" => "South Korea",
    "Türkiye" => "Turkey",
    "USA" => "United States"
  }.freeze

  before_validation :set_normalized_name

  validates :name, :emoji, :normalized_name, presence: true
  validates :name, :normalized_name, uniqueness: true

  def self.normalize(name)
    ActiveSupport::Inflector.transliterate(name.to_s).downcase.gsub(/[^a-z0-9]/, "")
  end

  def self.seed_defaults!
    DEFAULTS.each do |name, emoji|
      find_or_initialize_by(name: name).update!(emoji: emoji)
    end

    FOOTBALL_DATA_ALIASES.each do |country_name, aliases|
      country = find_by!(name: country_name)
      Array(aliases).each do |alias_name|
        country.aliases.find_or_initialize_by(source: "football_data", name: alias_name).save!
      end
    end
  end

  def self.by_name
    Rails.cache.fetch("countries/by_name", expires_in: 12.hours) { all.index_by(&:name) }
  end

  def self.by_normalized_name
    Rails.cache.fetch("countries/by_normalized_name", expires_in: 12.hours) { all.index_by(&:normalized_name) }
  end

  def self.by_alias(source)
    Rails.cache.fetch("countries/by_alias/#{source}", expires_in: 12.hours) do
      CountryAlias.includes(:country).where(source: source).index_by(&:normalized_name).transform_values(&:country)
    end
  end

  private
    def set_normalized_name
      self.normalized_name = self.class.normalize(name)
    end
end
