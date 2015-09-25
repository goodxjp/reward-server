# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :offer do
    association :medium
    association :campaign
    campaign_category_id 1
    name "オファー名"
    detail "詳細はこんな感じ。"
    icon_url "http://png.findicons.com/files/icons/1681/siena/128/currency_dollar_yellow.png"
    url "http://goodx.jp"
    requirement "何もしなくても OK"
    requirement_detail "努力すれば成果はつきます。"
    period "速攻"
    price 0
    payment 100
    payment_is_including_tax false
    point 50
    available true

    factory :offer_unavailable do
      available false
    end
  end
end
