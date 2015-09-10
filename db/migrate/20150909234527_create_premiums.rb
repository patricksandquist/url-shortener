class CreatePremiums < ActiveRecord::Migration
  def change
    add_column :users, :premium, :boolean, null: false, default: false
  end
end
