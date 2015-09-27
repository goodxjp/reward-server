# -*- coding: utf-8 -*-
FactoryGirl.define do
  sequence(:gift_codes) do |n|
    "123456789#{n}"
  end

  factory :gift do
    item
    code { FactoryGirl.generate(:gift_codes) }
    expiration_at Time.zone.now
    purchase_id nil
  end

  factory :gift_purchased, class: Gift do
    item
    code "1234567890A"
    expiration_at Time.zone.now
    purchase
  end
end
