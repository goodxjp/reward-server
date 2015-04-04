class Campaign < ActiveRecord::Base
  belongs_to :network
  has_many :advertisements
end
