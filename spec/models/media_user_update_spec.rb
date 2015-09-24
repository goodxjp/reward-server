# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe MediaUserUpdate, type: :model do
  it "media_user が必須" do
    media_user_update = build(:media_user_update, media_user: nil)
    media_user_update.valid?
    expect(media_user_update.errors[:media_user]).to include(I18n.t('errors.messages.empty'))
    # モデルに Validator をかけているので、外部キーにエラーは入らない。
    expect(media_user_update.errors[:media_user_id]).to eq []
  end
end
