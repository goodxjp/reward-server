# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :purchase do
    media_user
    item
    number 1
    point 100
    occurred_at Time.now
  end
end
