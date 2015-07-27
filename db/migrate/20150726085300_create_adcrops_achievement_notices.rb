class CreateAdcropsAchievementNotices < ActiveRecord::Migration
  def change
    create_table :adcrops_achievement_notices do |t|
      t.references :campaign_source, index: true
      t.string :suid
      t.string :xuid
      t.string :sad
      t.string :xad
      t.string :cv_id
      t.string :reward
      t.string :point

      t.timestamps
    end
  end
end
