class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.references :media_user, index: true, null: false
      t.references :item, index: true, null: false
      t.integer :number, null: false
      t.integer :point, null: false

      t.timestamps
    end
  end
end
