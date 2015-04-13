class Campaign < ActiveRecord::Base
  belongs_to :network
  has_many :advertisements

  has_and_belongs_to_many :media
end
