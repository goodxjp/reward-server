class ChangeOccuredAtToPurchase < ActiveRecord::Migration
  def change
    change_column_null :purchases, :occurred_at, false
    add_index :purchases, :occurred_at
  end
end
