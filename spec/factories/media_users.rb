# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :media_user do
    association :medium
    key "KEY012345"
    point 0
    total_point 0
  end
end
