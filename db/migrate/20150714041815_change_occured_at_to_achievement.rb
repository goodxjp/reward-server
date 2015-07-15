class ChangeOccuredAtToAchievement < ActiveRecord::Migration
  def change
    change_column_null :achievements, :occurred_at, false
    add_index :achievements, :occurred_at
  end
end
