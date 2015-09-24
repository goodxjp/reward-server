# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe TerminalAndroid, type: :model do
  it "media_user が必須" do
    terminal_android = build(:terminal_android, media_user: nil)
    terminal_android.valid?
    expect(terminal_android.errors[:media_user]).to include(I18n.t('errors.messages.empty'))
  end

  it "identifier が必須" do
    terminal_android = build(:terminal_android, identifier: nil)
    terminal_android.valid?
    expect(terminal_android.errors[:identifier]).to include(I18n.t('errors.messages.empty'))
  end

  it "available が必須" do
    terminal_android = build(:terminal_android, available: nil)
    terminal_android.valid?
    expect(terminal_android.errors[:available]).to include(I18n.t('errors.messages.empty'))
  end
end
