# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe Purchase, type: :model do
  specify 'point が必須' do
    purchase = Purchase.new(media_user_id: 1,
                            item_id: 1,
                            number: 1,
                            point: nil)
    expect(purchase).not_to be_valid
    expect(purchase.errors[:point]).to be_present
  end
end
