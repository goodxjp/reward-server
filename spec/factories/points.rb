# -*- coding: utf-8 -*-
FactoryGirl.define do
  factory :point do
    media_user
    point_type PointType::AUTO
    # TODO
    #association :source, factory: :campaign
    point 100
    remains 100
  end
end
