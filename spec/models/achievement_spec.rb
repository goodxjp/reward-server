# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  # TODO: この書き方がいいかどうか微妙
  describe 'Method dd_achievement' do
    it '超正常系' do
      media_user = FactoryGirl.create(:media_user)
      campaign = FactoryGirl.create(:campaign)

      Achievement.add_achievement(media_user, campaign, 0, false, 100, Time.zone.now, nil)
    end
  end
end
