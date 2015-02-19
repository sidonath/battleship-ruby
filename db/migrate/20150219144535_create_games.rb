class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.belongs_to :home_player, index: true
      t.belongs_to :guest_player, index: true
      t.text :map

      t.timestamps null: false
    end
    add_foreign_key :games, :home_players
    add_foreign_key :games, :guest_players
  end
end
