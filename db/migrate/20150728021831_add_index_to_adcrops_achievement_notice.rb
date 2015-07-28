class AddIndexToAdcropsAchievementNotice < ActiveRecord::Migration
  def change
    add_index :adcrops_achievement_notices, [:campaign_source_id, :cv_id], name: 'index_adcrops_an_on_campaign_source_id_and_cv_id'
  end
end
