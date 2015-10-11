class AddAvailableToMediaUser < ActiveRecord::Migration
  def change
    add_column :media_users, :available, :boolean, null: false, default: true
    remove_column :media_users, :terminal_id
    remove_column :media_users, :terminal_info
    remove_column :media_users, :android_registration_id
  end
end
