class PointHistory < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :source, polymorphic: true
end
