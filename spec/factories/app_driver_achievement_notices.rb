FactoryGirl.define do
  factory :app_driver_achievement_notice do
    campaign_source
    identifier "identifier"
    achieve_id "achieve_id"
    accepted_time "accepted_time"
    campaign_id "campaign_id"
    campaign_name "campaign_name"
    advertisement_id "advertisement_id"
    advertisement_name "advertisement_name"
    point "point"
    payment "payment"
  end
end
