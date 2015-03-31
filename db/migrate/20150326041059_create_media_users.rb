class CreateMediaUsers < ActiveRecord::Migration
  def change
    create_table :media_users do |t|
      t.string :terminal_id
      t.text :terminal_info
      t.string :android_registration_id

      t.timestamps
    end
  end
end
