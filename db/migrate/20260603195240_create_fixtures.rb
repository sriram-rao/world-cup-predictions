class CreateFixtures < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :fixtures, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.integer :match_number, null: false
      t.text :round_number, null: false
      t.datetime :match_date, null: false
      t.text :location, null: false
      t.text :home_team, null: false
      t.text :away_team, null: false
      t.text :group_name
    end

    add_index :fixtures, :match_number, unique: true
  end
end
