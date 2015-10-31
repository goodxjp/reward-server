class AddOccurredAtToPointHistory < ActiveRecord::Migration
  def change
    add_column :point_histories, :occurred_at, :datetime
    add_index :point_histories, :occurred_at
  end
end
