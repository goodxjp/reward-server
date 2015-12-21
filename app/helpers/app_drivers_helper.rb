# -*- coding: utf-8 -*-
module AppDriversHelper
  PLATFORM_TO_NAME = {
    1 => 'Universal (Web)',
    2 => 'iOS App',
    3 => 'Android App'
  }

  MARKET_TO_NAME = {
    1 => 'Google Play',
    2 => '独自マーケット',
    4 => 'au スマートパス',
    7 => 'App Store'
  }

  REQUISITE_TO_NAME = {
    1 => '有料アプリインストール',
    2 => '無料会員登録',
    3 => '有料会員登録',
    4 => 'キャンペーン・懸賞応募',
    5 => '商品購入',
    6 => 'サンプル請求',
    7 => 'アンケート・モニター登録',
    8 => '資料請求',
    9 => '見積・査定',
    10 => 'クレジットカード申込・発券',
    11 => 'キャッシング申込・成約',
    12 => '口座開設',
    13 => '予約・来店',
    14 => 'その他',
    15 => '無料アプリインストール',
    16 => 'ポイントバックなし',
    17 => 'アプリ起動',
    18 => 'インストール後チュートリアル完了',
    19 => 'インストール後ログイン',
    20 => 'インストール後会員登録',
    21 => 'auID記入後のログイン'
  }

  def label_platform(platform)
    attributes = {}
    case platform.to_i
    when 1
      attributes[:class] = "label label-info"
    when 2
      attributes[:class] = "label label-default"
    when 3
      attributes[:class] = "label label-primary"
    else
      attributes[:class] = "label label-danger"
    end

    content = "#{PLATFORM_TO_NAME[platform.to_i]} (#{platform.to_i})"

    content_tag(:span, attributes) do
      content
    end
  end

  def label_market(market)
    attributes = {}
    attributes[:class] = "label label-info"

    if market.blank?
      content = "マーケットなし"
    else
      content = "#{MARKET_TO_NAME[market.to_i]} (#{market.to_i})"
    end

    content_tag(:span, attributes) do
      content
    end
  end

  def label_requisite(requisite)
    attributes = {}
    attributes[:class] = "label label-info"

    content = "#{REQUISITE_TO_NAME[requisite.to_i]} (#{requisite.to_i})"

    content_tag(:span, attributes) do
      content
    end
  end
end
