class Mute < ActiveRecord::Base
  belongs_to :target, polymorphic: true
end
