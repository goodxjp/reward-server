# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :achievement do
    association :notification, factory: :gree_achievement_notice
    association :media_user
    association :campaign
    payment 100
    payment_is_including_tax false
    occurred_at Time.zone.now
  end
end
