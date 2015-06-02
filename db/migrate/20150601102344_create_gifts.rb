class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.references :item, index: true, null: false
      t.string :code, null: false
      t.datetime :expiration_at
      t.references :purchase, index: true

      t.timestamps
    end
  end
end
