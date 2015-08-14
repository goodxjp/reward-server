class CreateGreeConfigs < ActiveRecord::Migration
  def change
    create_table :gree_configs do |t|
      t.references :campaign_source, index: true, null: false
      t.integer :media_identifier, null: false
      t.string :site_key, null: false

      t.timestamps
    end
  end
end
