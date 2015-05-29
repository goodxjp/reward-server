class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.integer :point, null: false
      t.boolean :available, null: false, default: true

      t.timestamps
    end
  end
end
