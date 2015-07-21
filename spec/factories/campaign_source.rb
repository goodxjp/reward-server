# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :campaign_source do
    name "自社"
    network
  end

  factory :adcrops, class: CampaignSource do
    name "adcrops"
    network
  end
end
