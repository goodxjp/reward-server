class CreateMediaUserUpdates < ActiveRecord::Migration
  def change
    create_table :media_user_updates do |t|
      t.references :media_user, index: true, foreign_key: true
      t.datetime :last_access_at
      t.integer :app_version_code

      t.timestamps null: false
    end
  end
end
