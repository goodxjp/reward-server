class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.text :detail
      t.string :icon_url

      t.timestamps
    end
  end
end
