class Achievement < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :campaign
  belongs_to :point
end
