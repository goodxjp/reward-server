class AddMediaKeyToMediaUser < ActiveRecord::Migration
  def change
    add_reference :media_users, :medium, index: true
    add_column :media_users, :key, :string
  end
end
