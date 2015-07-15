class RenameTypeColumnToPoints < ActiveRecord::Migration
  def change
    rename_column :points, :type, :point_type_id
  end
end
