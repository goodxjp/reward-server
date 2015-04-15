class CreateCampaignCategories < ActiveRecord::Migration
  def change
    create_table :campaign_categories do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
