module FlagHelper
  def team_name_with_flag(name)
    emoji = CountryLookup.emoji_for(name)
    emoji ? "#{emoji} #{name}" : name
  end
end
