# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :app_driver_campaign do
    association :campaign_source
    identifier 1
    name "AppDriver キャンペーン名前"
    detail "AppDriver キャンペーン詳細"
    price 0
    advertisement_payment 100
    available true
  end
end
