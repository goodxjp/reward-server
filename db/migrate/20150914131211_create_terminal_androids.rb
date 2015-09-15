class CreateTerminalAndroids < ActiveRecord::Migration
  def change
    create_table :terminal_androids do |t|
      t.references :media_user, index: true, foreign_key: true
      t.string :identifier
      t.text :info
      t.string :android_version
      t.string :android_registration_id
      t.boolean :available

      t.timestamps null: false
    end
  end
end
