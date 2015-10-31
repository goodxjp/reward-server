# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :point_history do
    media_user
    point_change 100
    detail "100 ポイント取得"
    association :source, factory: :point
    occurred_at Time.zone.local(2000, 1, 1, 0, 0, 0)
  end
end
