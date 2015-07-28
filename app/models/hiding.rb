class Hiding < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :target, polymorphic: true
end
