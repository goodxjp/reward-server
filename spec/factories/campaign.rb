# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :campaign do
    network
    campaign_source
    name "テスト案件"
    detail "詳細はこんな感じ。"
    icon_url "http://png.findicons.com/files/icons/1681/siena/128/currency_dollar_yellow.png"
    url "http://goodx.jp"
    campaign_category_id "1"
    requirement "何もしなくても OK"
    requirement_detail "努力すれば成果はつきます。"
    period "速攻"
    price "0"
    payment "100"
    point "50"
  end
end
