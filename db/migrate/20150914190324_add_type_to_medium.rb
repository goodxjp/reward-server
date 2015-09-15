class AddTypeToMedium < ActiveRecord::Migration
  def change
    add_column :media, :media_type_id, :integer
    add_column :media, :at_least_app_version_code, :integer
  end
end
