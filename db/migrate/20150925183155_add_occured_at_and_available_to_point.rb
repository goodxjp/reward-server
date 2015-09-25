class AddOccuredAtAndAvailableToPoint < ActiveRecord::Migration
  def change
    add_column :points, :occurred_at, :datetime, null: false, default: '2000-01-01 00:00:00'
    add_index :points, :occurred_at
    add_column :points, :available, :boolean, null: false, default: true
    add_index :points, :available
  end
end
