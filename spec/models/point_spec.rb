# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe Point, type: :model do
  it "media_user が必須" do
    point = build(:point, media_user: nil)
    point.valid?
    expect(point.errors[:media_user]).to include(I18n.t('errors.messages.empty'))
  end
end
