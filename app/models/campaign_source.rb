class CampaignSource < ActiveRecord::Base
  belongs_to :network

  validates :network, :presence => true
  validates :name, :presence => true
end
