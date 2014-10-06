class CreateAdvertisements < ActiveRecord::Migration
  def change
    create_table :advertisements do |t|
      t.references :campaign, index: true
      t.integer :price
      t.integer :payment
      t.integer :point

      t.timestamps
    end
  end
end
