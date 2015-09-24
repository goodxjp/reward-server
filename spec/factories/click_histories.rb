# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :click_history do
    media_user
    offer
    request_info "リクエスト情報"
    ip_address "1.2.3.4"
  end
end
