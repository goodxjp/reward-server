class CreateGreeAchievementNotices < ActiveRecord::Migration
  def change
    create_table :gree_achievement_notices do |t|
      t.references :campaign_source, index: true
      t.string :identifier
      t.string :achieve_id
      t.string :point
      t.string :campaign_id
      t.string :advertisement_id
      t.string :media_session

      t.timestamps
    end

    add_index :gree_achievement_notices, [:campaign_source_id, :achieve_id], name: 'index_gree_an_on_campaign_source_id_and_achieve_id'
    add_index :gree_achievement_notices, [:campaign_source_id, :identifier, :advertisement_id], name: 'index_gree_an_on_cs_id_and_identifier_and_ad_id'
  end
end
