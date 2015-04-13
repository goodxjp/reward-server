class CreateCampaignsMedia < ActiveRecord::Migration
  def change
    create_table :campaigns_media, id: false do |t|
      t.references :campaign, index: true, null: false
      t.references :medium, index: true, null: false
    end
  end
end
