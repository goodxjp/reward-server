# -*- coding: utf-8 -*-
class ReportController < ApplicationController
  before_action :authenticate_admin_user!

  def sales
    @sales = []

    # TODO: View をネットワークが増えても対応出来るように、または、ID 1 のネットワークに対応

    # TODO: 選択可能に
    # 今月
    start_day = Date.today.beginning_of_month
    end_day   = start_day.end_of_month

    d = start_day
    while d <= end_day
      # SQL 用に当日と次の日の Time を作成
      from = Time.zone.local(d.year, d.month, d.day, 0, 0, 0)
      next_d = d.tomorrow
      to = Time.zone.local(next_d.year, next_d.month, next_d.day, 0, 0, 0)

      # 消費税率は日付によって異なる
      ct_rate = Config.consumption_tax_rate(from)

      sale = { day: d }

      networks = Network.all
      all_payment = 0  # 消費税も含めてしまう
      networks.each do |network|
        # 当日のネットワークの売上を集計
        payment_included_tax = Achievement.joins(:campaign).where("? <= occurred_at AND occurred_at < ?", from, to).where('campaigns.network_id = ?', network.id).where('achievements.payment_is_including_tax = ?', true).sum(:payment)
        payment_not_included_tax = Achievement.joins(:campaign).where("? <= occurred_at AND occurred_at < ?", from, to).where('campaigns.network_id = ?', network.id).where('achievements.payment_is_including_tax = ?', false).sum(:payment)

        # http://d.hatena.ne.jp/KEINOS/20130910
        tax = (payment_included_tax * ct_rate / (1 + ct_rate)).round + (payment_not_included_tax * ct_rate).round
        payment = payment_included_tax - (payment_included_tax * ct_rate / (1 + ct_rate)).round + payment_not_included_tax

        # TODO: 消費税関係の変数名統一
        sale["network_#{network.id}"] = {}
        sale["network_#{network.id}"][:payment] = payment
        sale["network_#{network.id}"][:tax] = tax
        all_payment += payment + tax  # 多分、しばらくは消費税も利益に上げちゃっていい。
      end

      # 当日の発行ポイントを集計
      # TODO ポイントに発生日時追加
      published_point = Point.where("? <= created_at AND created_at < ?", from, to).sum(:point)
      sale[:published_point] = published_point

      # 当日の交換ポイントを集計
      exchanged_point = Purchase.where("? <= occurred_at AND occurred_at < ?", from, to).sum(:point)
      sale[:exchanged_point] = exchanged_point

      # 当日の利益 (売上 (税込) - 発行ポイント)
      sale[:profit] = all_payment - published_point

      @sales << sale
      d = d + 1.days
    end
  end

  def campaigns
    #start_day = Date.today.beginning_of_month
    #end_day   = start_day.end_of_month
    start_day = Date.new(2015, 1, 1)
    end_day   = Date.new(2100, 12, 31)

    @reports = []

    # SQL 用に Time を作成
    from = Time.zone.local(start_day.year, start_day.month, start_day.day, 0, 0, 0)
    next_d = end_day.tomorrow
    to = Time.zone.local(next_d.year, next_d.month, next_d.day, 0, 0, 0)

    # TODO: 今は全期間共通の消費税。将来的に日ごとに消費税の計算を事前に行っておく
    ct_rate = Config.consumption_tax_rate(from)

    campaign_ids = Achievement.group(:campaign_id).where("? <= occurred_at AND occurred_at < ?", from, to).select('campaign_id, COUNT(*) AS count').order(:campaign_id)

    campaign_ids.each do |campaign_id|
      campaign = Campaign.find(campaign_id.campaign_id)

      # 売上を集計
      payment_included_tax = Achievement.where("? <= occurred_at AND occurred_at < ?", from, to).where('campaign_id = ?', campaign.id).where('payment_is_including_tax = ?', true).sum(:payment)
      payment_not_included_tax = Achievement.where("? <= occurred_at AND occurred_at < ?", from, to).where('campaign_id = ?', campaign.id).where('payment_is_including_tax = ?', false).sum(:payment)

      # http://d.hatena.ne.jp/KEINOS/20130910
      tax = (payment_included_tax * ct_rate / (1 + ct_rate)).round + (payment_not_included_tax * ct_rate).round
      payment = payment_included_tax - (payment_included_tax * ct_rate / (1 + ct_rate)).round + payment_not_included_tax

      # 発行ポイントを集計
      published_point = Achievement.joins(:points).where("? <= occurred_at AND occurred_at < ?", from, to).where('campaign_id = ?', campaign.id).sum('points.point')

      report = {}
      report[:campaign] = campaign
      report[:count] = campaign_id.count
      report[:payment] = payment
      report[:tax] = tax
      report[:published_point] = published_point
      report[:profit] = payment + tax - published_point

      @reports << report
    end
  end
end

