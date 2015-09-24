# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :point_history do
    media_user
    point_change 100
    detail "100 ポイント取得"
    association :source, factory: :point
  end
end
