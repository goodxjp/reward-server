class AddOccuredAtToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :occurred_at, :datetime
  end
end
