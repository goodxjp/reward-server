# -*- coding: utf-8 -*-
module GreeCampaignsHelper
  def label_campaign_category(campaign_category)
    attributes = {}
    case campaign_category.to_i
    when 1
      attributes[:class] = "label label-primary"
      content = "インストール（無料/ポイントアプリ以外）"
      content << "(#{campaign_category})"
    when 2
      attributes[:class] = "label label-primary"
      content = "インストール（有料）"
      content << "(#{campaign_category})"
    when 3
      attributes[:class] = "label label-info"
      content = "GREEゲーム"
      content << "(#{campaign_category})"
    when 5
      attributes[:class] = "label label-info"
      content = "月額（無料）"
      content << "(#{campaign_category})"
    when 6
      attributes[:class] = "label label-info"
      content = "月額（有料）"
      content << "(#{campaign_category})"
    when 7
      attributes[:class] = "label label-info"
      content = "スマートパスAコース（インストール）"
      content << "(#{campaign_category})"
    when 8
      attributes[:class] = "label label-info"
      content = "スマートパスAコース（初回アクセス）"
      content << "(#{campaign_category})"
    when 9
      attributes[:class] = "label label-info"
      content = "スマートパスAコース（その他）"
      content << "(#{campaign_category})"
    when 10
      attributes[:class] = "label label-info"
      content = "スマートパスBコース（インストール）"
      content << "(#{campaign_category})"
    when 11
      attributes[:class] = "label label-info"
      content = "スマートパスBコース（初回アクセス）"
      content << "(#{campaign_category})"
    when 12
      attributes[:class] = "label label-info"
      content = "スマートパスBコース（その他）"
      content << "(#{campaign_category})"
    when 13
      attributes[:class] = "label label-info"
      content = "クレジットカード（申込・発券）"
      content << "(#{campaign_category})"
    when 14
      attributes[:class] = "label label-info"
      content = "キャッシング（申込・成約）"
      content << "(#{campaign_category})"
    when 15
      attributes[:class] = "label label-info"
      content = "口座開設"
      content << "(#{campaign_category})"
    when 16
      attributes[:class] = "label label-info"
      content = "商品購入"
      content << "(#{campaign_category})"
    when 17
      attributes[:class] = "label label-info"
      content = "サンプル請求"
      content << "(#{campaign_category})"
    when 18
      attributes[:class] = "label label-info"
      content = "アンケートモニター登録"
      content << "(#{campaign_category})"
    when 19
      attributes[:class] = "label label-info"
      content = "無料会員登録（ポイントサイト以外）"
      content << "(#{campaign_category})"
    when 20
      attributes[:class] = "label label-info"
      content = "資料請求"
      content << "(#{campaign_category})"
    when 21
      attributes[:class] = "label label-info"
      content = "見積もり・査定"
      content << "(#{campaign_category})"
    when 22
      attributes[:class] = "label label-info"
      content = "キャンペーン・鑑賞応募"
      content << "(#{campaign_category})"
    when 23
      attributes[:class] = "label label-info"
      content = "予約・来店"
      content << "(#{campaign_category})"
    when 24
      attributes[:class] = "label label-info"
      content = "Video視聴"
      content << "(#{campaign_category})"
    when 25
      attributes[:class] = "label label-info"
      content = "その他（ポイントアプリ・ポイントサイト以外）"
      content << "(#{campaign_category})"
    when 26
      attributes[:class] = "label label-info"
      content = "インストール（無料/ポイントアプリ）"
      content << "(#{campaign_category})"
    when 27
      attributes[:class] = "label label-info"
      content = "無料会員登録（ポイントサイト）"
      content << "(#{campaign_category})"
    when 28
      attributes[:class] = "label label-info"
      content = "その他（ポイントアプリ・ポイントサイト）"
      content << "(#{campaign_category})"
    else
      attributes[:class] = "label label-danger"
      content = "(#{campaign_category})"
    end

    content_tag(:span, attributes) do
      content
    end
  end

  def label_thanks_category(thanks_category)
    attributes = {}
    case thanks_category.to_i
    when 1
      attributes[:class] = "label label-primary"
      content = "インストール"
      content << "(#{thanks_category})"
    when 2
      attributes[:class] = "label label-info"
      content = "無料会員登録"
      content << "(#{thanks_category})"
    when 3
      attributes[:class] = "label label-info"
      content = "有料会員登録"
      content << "(#{thanks_category})"
    when 4
      attributes[:class] = "label label-info"
      content = "キャンペーン・懸賞応募"
      content << "(#{thanks_category})"
    when 5
      attributes[:class] = "label label-info"
      content = "商品購入"
      content << "(#{thanks_category})"
    when 6
      attributes[:class] = "label label-info"
      content = "サンプル請求"
      content << "(#{thanks_category})"
    when 7
      attributes[:class] = "label label-info"
      content = "アンケート・モニター登録"
      content << "(#{thanks_category})"
    when 8
      attributes[:class] = "label label-info"
      content = "資料請求"
      content << "(#{thanks_category})"
    when 9
      attributes[:class] = "label label-info"
      content = "見積・査定"
      content << "(#{thanks_category})"
    when 10
      attributes[:class] = "label label-info"
      content = "クレジットカード申込・発券"
      content << "(#{thanks_category})"
    when 11
      attributes[:class] = "label label-info"
      content = "キャッシング申込・成約"
      content << "(#{thanks_category})"
    when 12
      attributes[:class] = "label label-info"
      content = "口座開設"
      content << "(#{thanks_category})"
    when 13
      attributes[:class] = "label label-info"
      content = "予約・来店"
      content << "(#{thanks_category})"
    when 14
      attributes[:class] = "label label-info"
      content = "その他"
      content << "(#{thanks_category})"
    when 15
      attributes[:class] = "label label-info"
      content = "Video視聴"
      content << "(#{thanks_category})"
    when 16
      attributes[:class] = "label label-info"
      content = "条件達成（チュートリアル完了・ビンゴ達成等）"
      content << "(#{thanks_category})"
    else
      attributes[:class] = "label label-danger"
      content = "(#{thanks_category})"
    end

    content_tag(:span, attributes) do
      content
    end
  end

  def label_platform_identifier(platform_identifier)
    attributes = {}
    case platform_identifier.to_i
    when 1
      attributes[:class] = "label label-info"
      content = "Web (#{platform_identifier})"
    when 2
      attributes[:class] = "label label-default"
      content = "iOS (#{platform_identifier})"
    when 3
      attributes[:class] = "label label-primary"
      content = "Android (#{platform_identifier})"
    else
      attributes[:class] = "label label-danger"
      content = "(#{platform_identifier})"
    end

    content_tag(:span, attributes) do
      content
    end
  end
end
