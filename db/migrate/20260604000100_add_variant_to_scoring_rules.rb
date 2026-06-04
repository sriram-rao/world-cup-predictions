class AddVariantToScoringRules < ActiveRecord::Migration[8.1]
  def up
    add_column :scoring_rules, :variant, :string, null: false, default: "standard"

    execute <<~SQL.squish
      DELETE FROM scoring_rules a
      USING scoring_rules b
      WHERE a.variant = b.variant
        AND a.created_at > b.created_at
    SQL

    add_index :scoring_rules, :variant, unique: true
  end

  def down
    remove_index :scoring_rules, :variant
    remove_column :scoring_rules, :variant
  end
end
