# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :purchase do
    media_user
    item
    number 1
    point 100
    occurred_at Time.zone.local(2000, 1, 1, 0, 0, 0)
  end
end
