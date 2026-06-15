class CreateCountries < ActiveRecord::Migration[8.1]
  def change
    create_table :countries, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.string :emoji, null: false
      t.string :normalized_name, null: false

      t.timestamps
    end

    create_table :country_aliases, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :country, null: false, foreign_key: true, type: :uuid
      t.string :source, null: false
      t.string :name, null: false
      t.string :normalized_name, null: false

      t.timestamps
    end

    add_index :countries, :name, unique: true
    add_index :countries, :normalized_name, unique: true
    add_index :country_aliases, %i[source normalized_name], unique: true
  end
end
