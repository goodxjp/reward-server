class Campaign < ActiveRecord::Base
  belongs_to :network
  belongs_to :campaign_category
  has_many :advertisements

  has_and_belongs_to_many :media

  validates :name, :presence => true
  validates :network, :presence => true
  validates :url, :presence => true
end
