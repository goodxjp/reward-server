# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe AppDriverCampaign, type: :model do
  describe "#corresponding_campaign" do
    it "対応するキャンペーンを取得できる" do
      app_driver_campaign = create(:app_driver_campaign)
      campaign = create(:campaign,
                        campaign_source: app_driver_campaign.campaign_source,
                        source_campaign_identifier: app_driver_campaign.identifier)

      result_campaign = app_driver_campaign.corresponding_campaign

      expect(result_campaign).to eq campaign
    end

    it "campaign_source の異なるキャンペーンを取得しない" do
      campaign_source_1 = create(:campaign_source)
      campaign_source_2 = create(:campaign_source)
      app_driver_campaign = create(:app_driver_campaign, campaign_source: campaign_source_1)
      campaign = create(:campaign,
                        campaign_source: campaign_source_2,
                        source_campaign_identifier: app_driver_campaign.identifier)

      # campaign_source_1 と campaign_source_2 は別物？
      #puts campaign_source_1.id
      #puts campaign_source_2.id

      result_campaign = app_driver_campaign.corresponding_campaign

      expect(result_campaign).to be_nil
    end

    it "source_campaign_identifier の異なるキャンペーンを取得しない" do
      campaign_source = create(:campaign_source)
      app_driver_campaign = create(:app_driver_campaign, campaign_source: campaign_source)
      campaign = create(:campaign,
                        campaign_source: campaign_source,
                        source_campaign_identifier: app_driver_campaign.identifier + 1)

      result_campaign = app_driver_campaign.corresponding_campaign

      expect(result_campaign).to be_nil
    end

    it "対応するキャンペーンが複数ある場合は取得しない" do
      # と思ったが、そもそもそんなキャンペーンを作れない

      # campaign_source = create(:campaign_source)
      # app_driver_campaign = create(:app_driver_campaign, campaign_source: campaign_source)
      # campaign_1 = create(:campaign,
      #                     campaign_source: campaign_source,
      #                     source_campaign_identifier: app_driver_campaign.identifier)
      # campaign_2 = create(:campaign,
      #                     campaign_source: campaign_source,
      #                     source_campaign_identifier: app_driver_campaign.identifier)

      # result_campaign = app_driver_campaign.corresponding_campaign

      # expect(result_campaign).to be_nil
    end
  end
end
