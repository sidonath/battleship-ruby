class AddCodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :code, :text
  end
end
