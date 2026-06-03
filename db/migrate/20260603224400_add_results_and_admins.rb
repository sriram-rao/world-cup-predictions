class AddResultsAndAdmins < ActiveRecord::Migration[8.1]
  def change
    add_column :fixtures, :home_score, :integer
    add_column :fixtures, :away_score, :integer
    add_column :users, :admin, :boolean, null: false, default: false

    add_check_constraint :fixtures, "home_score >= 0", name: "fixtures_home_score_non_negative"
    add_check_constraint :fixtures, "away_score >= 0", name: "fixtures_away_score_non_negative"
  end
end
