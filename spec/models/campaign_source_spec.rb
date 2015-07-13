# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe CampaignSource, type: :model do
  specify 'network が必須' do
    campaign_source = CampaignSource.new(network_id: nil, name: "Test")
    expect(campaign_source).not_to be_valid
    expect(campaign_source.errors[:network]).to be_present
  end

  specify 'name が必須' do
    campaign_source = CampaignSource.new(network_id: 1, name: nil)
    expect(campaign_source).not_to be_valid
    expect(campaign_source.errors[:name]).to be_present
  end
end
