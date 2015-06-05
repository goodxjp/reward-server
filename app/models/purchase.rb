class Purchase < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :item

  validates :media_user,
    :presence => true
  validates :item,
    :presence => true
  validates :number,
    :presence => true
  validates :point,
    :presence => true
end
