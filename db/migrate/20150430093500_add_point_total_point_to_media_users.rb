class AddPointTotalPointToMediaUsers < ActiveRecord::Migration
  def change
    add_column :media_users, :point, :integer, :null => false, :default => 0
    add_column :media_users, :total_point, :integer, :null => false, :default => 0
  end
end
