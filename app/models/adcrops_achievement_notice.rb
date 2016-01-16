class AdcropsAchievementNotice < ActiveRecord::Base
  belongs_to :campaign_source

  def type_name
    "adcrop"
  end
end
