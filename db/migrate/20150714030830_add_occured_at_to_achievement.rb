class AddOccuredAtToAchievement < ActiveRecord::Migration
  def change
    add_column :achievements, :occurred_at, :datetime, index: true
    add_reference :achievements, :notification, polymorphic: true, index: true
    remove_column :achievements, :point_id, :integer
    remove_column :achievements, :accrual_date, :string
  end
end
