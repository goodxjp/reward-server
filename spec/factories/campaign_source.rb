# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :campaign_source do
    name "実在しないキャンペーンソース"
    network
  end

  factory :adcrops, class: CampaignSource do
    name "adcrops"
    network_system NetworkSystem::ADCROPS
    network
  end

  factory :campaign_source_gree, class: CampaignSource do
    name "GREE"
    network_system NetworkSystem::GREE
    network
  end
end
