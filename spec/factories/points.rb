# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :point do
    association :media_user
    point 100
    remains 100
    occurred_at Time.zone.now
    expiration_at Time.zone.now + 1.days
    available true
    point_type PointType::AUTO
    association :source, factory: :achievement
  end
end
