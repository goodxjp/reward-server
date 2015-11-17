FactoryGirl.define do
  factory :gree_config do
    association :campaign_source
    site_identifier 1002
    media_identifier 106
    site_key "GREE_CONFIG_SITE_KEY"
  end
end
