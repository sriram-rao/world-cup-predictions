class AddCapeVerdeIslandsAlias < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      INSERT INTO country_aliases (id, country_id, source, name, normalized_name, created_at, updated_at)
      SELECT gen_random_uuid(), countries.id, 'football_data', 'Cape Verde Islands', 'capeverdeislands', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM countries
      WHERE countries.name = 'Cabo Verde'
      ON CONFLICT (source, normalized_name) DO UPDATE
      SET country_id = EXCLUDED.country_id,
          name = EXCLUDED.name,
          updated_at = CURRENT_TIMESTAMP
    SQL
  end

  def down
    execute <<~SQL.squish
      DELETE FROM country_aliases
      WHERE source = 'football_data' AND normalized_name = 'capeverdeislands'
    SQL
  end
end
