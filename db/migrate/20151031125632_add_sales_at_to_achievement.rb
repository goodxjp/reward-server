class AddSalesAtToAchievement < ActiveRecord::Migration
  def change
    add_column :achievements, :sales_at, :datetime
    add_index :achievements, :sales_at
  end
end
