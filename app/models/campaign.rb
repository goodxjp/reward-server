class Campaign < ActiveRecord::Base
  has_many :advertisements
end