# -*- coding: utf-8 -*-
class CampaignSource < ActiveRecord::Base
  belongs_to :network
  belongs_to :network_system

  validates :network, :presence => true
  validates :name, :presence => true
end
