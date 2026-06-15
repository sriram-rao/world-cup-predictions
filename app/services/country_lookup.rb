class CountryLookup
  FOOTBALL_DATA = "football_data"

  def self.emoji_for(name)
    Country.by_name[name]&.emoji
  end

  def self.from_football_data(name)
    normalized = Country.normalize(name)
    Country.by_alias(FOOTBALL_DATA)[normalized] || Country.by_normalized_name[normalized]
  end
end
