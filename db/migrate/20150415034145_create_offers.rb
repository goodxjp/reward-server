class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.references :campaign, index: true, null: false
      t.references :medium, index: true, null: false
      t.references :campaign_category, index: true
      t.string :name
      t.text :detail
      t.string :icon_url
      t.string :url
      t.string :requirement
      t.text :requirement_detail
      t.string :period
      t.integer :price
      t.integer :payment
      t.integer :point

      t.timestamps
    end
  end
end
