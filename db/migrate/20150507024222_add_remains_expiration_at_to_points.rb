class AddRemainsExpirationAtToPoints < ActiveRecord::Migration
  def up
    add_column :points, :remains, :integer
    add_column :points, :expiration_at, :datetime
    change_column :points, :remains, :integer, null: false
  end

  def down
    remove_column :points, :remains
    remove_column :points, :expiration_at
  end
end
