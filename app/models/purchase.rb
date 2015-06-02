class Purchase < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :item
end
