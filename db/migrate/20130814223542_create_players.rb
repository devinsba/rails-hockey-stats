class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :nhl_id
      t.string :last_name
      t.string :first_name

      t.timestamps
    end
  end
end
