# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe ClickHistory, type: :model do
  describe ".find_by_media_user_and_campaign" do
    it '超正常系' do
      media_user1 = create(:media_user)
      media_user2 = create(:media_user)
      campaign1 = create(:campaign)
      campaign2 = create(:campaign)
      offer1 = create(:offer, campaign: campaign1)
      offer2 = create(:offer, campaign: campaign2)
      offer3 = create(:offer, campaign: campaign1)
      click_history1 = create(:click_history, media_user: media_user1, offer: offer1)
      click_history2 = create(:click_history, media_user: media_user1, offer: offer2)
      click_history3 = create(:click_history, media_user: media_user1, offer: offer3)
      click_history4 = create(:click_history, media_user: media_user2, offer: offer3)

      click_histories = ClickHistory.find_all_by_media_user_and_campaign(media_user1, campaign1).to_a
      result_click_history1 = click_histories.find { |ch| ch.offer_id == offer1.id }
      result_click_history2 = click_histories.find { |ch| ch.offer_id == offer3.id }

      expect(click_histories.size).to eq 2
      expect(result_click_history1.id).to eq click_history1.id
      expect(result_click_history2.id).to eq click_history3.id
    end
  end
end
