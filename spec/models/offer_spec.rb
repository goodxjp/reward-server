# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe Offer, type: :model do
  it 'medium が必須' do
    offer = build(:offer, medium: nil)
    offer.valid?
    expect(offer.errors[:medium]).to include(I18n.t('errors.messages.empty'))
  end

  describe ".offer_from_campaign_and_medium" do
    it '超正常系' do
      medium = create(:medium)
      campaign = create(:campaign)

      # キャンペーンに「対応しないオファー (offer1)」と「対応するオファー (offer2)」を生成する
      #offer = create(:offer, campaign: campaign, medium: medium)
      offer1 = Offer.new_from_campaign(campaign, medium)
      offer1.name = "違う名前"
      offer1.save!
      offer2 = Offer.new_from_campaign(campaign, medium)
      offer2.save!

      result_offer = Offer.offer_from_campaign_and_medium(campaign, medium)

      expect(result_offer).not_to be_nil
      expect(result_offer.id).to eq offer2.id
    end

    it '対応するオファーが存在しない場合は nil を返す' do
      medium = create(:medium)
      campaign = create(:campaign)

      # キャンペーンに「対応しないオファー」のみを生成する
      offer1 = Offer.new_from_campaign(campaign, medium)
      offer1.name = "違う名前"
      offer1.save!
      offer2 = Offer.new_from_campaign(campaign, medium)
      offer2.point = 1000000
      offer2.save!

      result_offer = Offer.offer_from_campaign_and_medium(campaign, medium)

      expect(result_offer).to be_nil
    end

    it 'available だけが異なっているオファーを返す' do
      medium = create(:medium)
      campaign = create(:campaign)

      # キャンペーンに「対応しないオファー」のみを生成する
      offer1 = Offer.new_from_campaign(campaign, medium)
      offer1.name = "違う名前"
      offer1.save!
      offer2 = Offer.new_from_campaign(campaign, medium)
      offer2.available = (not offer2.available)
      offer2.save!

      result_offer = Offer.offer_from_campaign_and_medium(campaign, medium)

      expect(result_offer).not_to be_nil
      expect(result_offer.id).to eq offer2.id
    end
  end
end
