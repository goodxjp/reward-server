# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe GreeConfig, type: :model do
  it "campaign_source が必須" do
    gree_config = build(:gree_config, campaign_source: nil)
    gree_config.valid?
    expect(gree_config.errors[:campaign_source]).to include(I18n.t('errors.messages.empty'))
  end

  it "media_identifier が必須" do
    gree_config = build(:gree_config, media_identifier: nil)
    gree_config.valid?
    expect(gree_config.errors[:media_identifier]).to include(I18n.t('errors.messages.empty'))
  end

  it "site_key が必須" do
    gree_config = build(:gree_config, site_key: nil)
    gree_config.valid?
    expect(gree_config.errors[:site_key]).to include(I18n.t('errors.messages.empty'))
  end
end
