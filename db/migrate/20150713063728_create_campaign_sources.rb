class CreateCampaignSources < ActiveRecord::Migration
  def change
    create_table :campaign_sources do |t|
      t.references :network, index: true, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
