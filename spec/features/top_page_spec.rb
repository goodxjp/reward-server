# -*- coding: utf-8 -*-
require 'rails_helper'

describe 'トップページ' do
  specify 'ログイン画面表示' do
    visit root_path
    expect(page).to have_css('p', text: 'ログイン')
  end
end

