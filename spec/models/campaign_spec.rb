# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it 'payment が必須' do
    campaign = build(:campaign, payment: nil)
    campaign.valid?
    expect(campaign.errors[:payment]).to include(I18n.t('errors.messages.empty'))
  end

  describe "#update_related_offers" do
    it '超正常系' do
      medium1 = create(:medium)
      medium2 = create(:medium)
      campaign = create(:campaign, available: true)
      campaign.media << medium1
      offer2 = create(:offer, campaign: campaign, medium: medium2, available: true)

      campaign.update_related_offers

      expect(campaign.offers.size).to eq 2
      result_offer1 = campaign.offers.where(medium: medium1)[0]
      result_offer2 = campaign.offers.where(medium: medium2)[0]
      expect(result_offer1.name).to eq campaign.name
      expect(result_offer1.equal?(campaign)).to eq true
      expect(result_offer1.available).to eq true
      expect(result_offer2.id).to eq offer2.id
      expect(result_offer2.available).to eq false
    end

    context 'キャンペーンが有効' do
      it '対応したオファーが追加される' do
        medium1 = create(:medium)
        campaign = create(:campaign, available: true)
        campaign.media << medium1

        campaign.update_related_offers

        expect(campaign.offers.size).to eq 1
        result_offer = campaign.offers[0]
        expect(result_offer.name).to eq campaign.name
        expect(result_offer.equal?(campaign)).to eq true
        expect(result_offer.available).to eq true
      end

      it 'すでに対応したオファーが存在した場合はそのオファーが有効になる' do
        medium1 = create(:medium)
        campaign = create(:campaign, available: true)
        campaign.media << medium1
        #offer1 = create(:offer, campaign: campaign, medium: medium1, available: true)
        offer1 = Offer.new_from_campaign(campaign, medium1)
        offer1.available = false
        offer1.save!

        campaign.update_related_offers

        expect(campaign.offers.size).to eq 1
        result_offer = campaign.offers[0]
        expect(result_offer.name).to eq campaign.name
        expect(result_offer.equal?(campaign)).to eq true
        expect(result_offer.available).to eq true
      end

      it '対応メディアで内容の異なるオファーが無効になる' do
        medium1 = create(:medium)
        campaign = create(:campaign, available: true)
        campaign.media << medium1
        #offer1 = create(:offer, campaign: campaign, medium: medium1, available: true)
        offer1 = Offer.new_from_campaign(campaign, medium1)
        offer1.point = offer1.point + 1
        offer1.available = true
        offer1.save!

        campaign.update_related_offers

        expect(campaign.offers.size).to eq 2
        result_offer1 = campaign.offers.where(point: campaign.point + 1)[0]
        result_offer2 = campaign.offers.where(point: campaign.point)[0]
        expect(result_offer1.name).to eq campaign.name
        expect(result_offer1.point).to eq campaign.point + 1
        expect(result_offer1.available).to eq false
        expect(result_offer2.name).to eq campaign.name
        expect(result_offer2.equal?(campaign)).to eq true
        expect(result_offer2.available).to eq true
      end

      it '対応メディアではなくて内容の同じオファーが無効になる' do
        medium1 = create(:medium)
        medium2 = create(:medium)
        campaign = create(:campaign, available: true)
        campaign.media << medium2
        #offer1 = create(:offer, campaign: campaign, medium: medium1, available: true)
        offer1 = Offer.new_from_campaign(campaign, medium1)
        offer1.available = true
        offer1.save!

        campaign.update_related_offers

        expect(campaign.offers.size).to eq 2
        result_offer1 = campaign.offers.where(medium: medium1)[0]
        result_offer2 = campaign.offers.where(medium: medium2)[0]
        expect(result_offer1.name).to eq campaign.name
        expect(result_offer1.point).to eq campaign.point
        expect(result_offer1.available).to eq false
        expect(result_offer2.name).to eq campaign.name
        expect(result_offer2.equal?(campaign)).to eq true
        expect(result_offer2.available).to eq true
      end
    end

    context 'キャンペーンが無効' do
      it '全てのオファーが無効になる' do
        medium1 = create(:medium)
        campaign = create(:campaign, available: false)
        campaign.media << medium1
        #offer1 = create(:offer, campaign: campaign, medium: medium1, available: true)
        offer1 = Offer.new_from_campaign(campaign, medium1)
        offer1.available = true
        offer1.save!

        campaign.update_related_offers

        expect(campaign.offers.size).to eq 1
        result_offer = campaign.offers[0]
        expect(result_offer.name).to eq campaign.name
        expect(result_offer.equal?(campaign)).to eq true
        expect(result_offer.available).to eq false
      end
    end
  end
end
