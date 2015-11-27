# -*- coding: utf-8 -*-
class ReportController < ApplicationController
  before_action :authenticate_admin_user!

  def sales
    #
    # 表示期間の決定
    #
    # TODO: エラー処理真面目に
    if params[:report_period_form].nil?
      @form = ReportPeriodForm.new()
      start_day = Date.today.beginning_of_month
      end_day   = start_day.end_of_month
    else
      @form = ReportPeriodForm.new(params.require(:report_period_form))
      begin
        start_day = Date.strptime(@form.start, "%Y/%m/%d")
      rescue ArgumentError
        start_day = Date.today.beginning_of_month
      end
      begin
        end_day = Date.strptime(@form.end, "%Y/%m/%d")
      rescue ArgumentError
        end_day   = start_day.end_of_month
      end
    end

    if end_day - start_day > 100
      end_day = start_day + 100
    end

    @form.start = start_day.strftime("%Y/%m/%d")
    @form.end = end_day.strftime("%Y/%m/%d")


    @report_data = []

    # TODO: View をネットワークが増えても対応出来るように、または、ID 1 のネットワークに対応

    d = start_day
    while d <= end_day
      # SQL 用に当日と次の日の Time を作成
      from = Time.zone.local(d.year, d.month, d.day, 0, 0, 0)
      next_d = d.tomorrow
      to = Time.zone.local(next_d.year, next_d.month, next_d.day, 0, 0, 0)

      # 消費税率は日付によって異なる
      ct_rate = Setting.consumption_tax_rate(from)

      # 1 行分のデータ
      row = { day: d }

      networks = Network.all
      all_payment_including_tax = 0  # 今のところ、all_payment に消費税も含めてしまう
      networks.each do |network|
        # 当日 (d) のネットワークの売上を集計
        sum_payment_including_tax = Achievement.joins(:campaign).where("? <= occurred_at AND occurred_at < ?", from, to).where('campaigns.network_id = ?', network.id).where('achievements.payment_is_including_tax = ?', true).sum(:payment)
        sum_payment_excluding_tax = Achievement.joins(:campaign).where("? <= occurred_at AND occurred_at < ?", from, to).where('campaigns.network_id = ?', network.id).where('achievements.payment_is_including_tax = ?', false).sum(:payment)

        # http://d.hatena.ne.jp/KEINOS/20130910
        payment_consumption_tax =
          (sum_payment_including_tax * ct_rate / (1 + ct_rate)).round +
          (sum_payment_excluding_tax * ct_rate).round
        payment_excluding_tax =
          sum_payment_including_tax - (sum_payment_including_tax * ct_rate / (1 + ct_rate)).round +
          sum_payment_excluding_tax

        row["network_#{network.id}"] = {}
        row["network_#{network.id}"][:payment_excluding_tax] = payment_excluding_tax
        row["network_#{network.id}"][:payment_consumption_tax] = payment_consumption_tax
        all_payment_including_tax += payment_excluding_tax + payment_consumption_tax  # しばらくは消費税も利益に上げちゃう。
      end

      # 当日の発行ポイントを集計
      published_point = Point.where("? <= occurred_at AND occurred_at < ?", from, to).sum(:point)
      row[:published_point] = published_point

      # 当日の交換ポイントを集計
      exchanged_point = Purchase.where("? <= occurred_at AND occurred_at < ?", from, to).sum(:point)
      row[:exchanged_point] = exchanged_point

      # 当日の利益 (売上 (税込) - 発行ポイント)
      row[:profit] = all_payment_including_tax - published_point

      @report_data << row
      d = d + 1.days
    end
  end

  def campaigns
    #start_day = Date.today.beginning_of_month
    #end_day   = start_day.end_of_month
    start_day = Date.new(2015, 1, 1)
    end_day   = Date.new(2100, 12, 31)

    @report_data = []

    # SQL 用に Time を作成
    from = Time.zone.local(start_day.year, start_day.month, start_day.day, 0, 0, 0)
    next_d = end_day.tomorrow
    to = Time.zone.local(next_d.year, next_d.month, next_d.day, 0, 0, 0)

    # TODO: 今は全期間共通の消費税。将来的に日ごとに消費税の計算を事前に行っておく
    ct_rate = Setting.consumption_tax_rate(from)

    # 対象期間に成果のあったキャンペーン ID を全て取得
    campaign_ids = Achievement.group(:campaign_id).where("? <= occurred_at AND occurred_at < ?", from, to).select('campaign_id, COUNT(*) AS count').order(:campaign_id)

    campaign_ids.each do |campaign_id|
      campaign = Campaign.find(campaign_id.campaign_id)

      # 売上を集計
      sum_payment_including_tax = Achievement.where("? <= occurred_at AND occurred_at < ?", from, to).where('campaign_id = ?', campaign.id).where('payment_is_including_tax = ?', true).sum(:payment)
      sum_payment_excluding_tax = Achievement.where("? <= occurred_at AND occurred_at < ?", from, to).where('campaign_id = ?', campaign.id).where('payment_is_including_tax = ?', false).sum(:payment)

      # http://d.hatena.ne.jp/KEINOS/20130910
      payment_consumption_tax =
        (sum_payment_including_tax * ct_rate / (1 + ct_rate)).round +
        (sum_payment_excluding_tax * ct_rate).round
      payment_excluding_tax =
        sum_payment_including_tax - (sum_payment_including_tax * ct_rate / (1 + ct_rate)).round +
        sum_payment_excluding_tax

      # 発行ポイントを集計
      published_point = Achievement.joins(:points).where("? <= points.occurred_at AND points.occurred_at < ?", from, to).where('campaign_id = ?', campaign.id).sum('points.point')

      row= {}
      row[:campaign] = campaign
      row[:count] = campaign_id.count
      row[:payment_excluding_tax] = payment_excluding_tax
      row[:payment_consumption_tax] = payment_consumption_tax
      row[:published_point] = published_point
      row[:profit] = payment_excluding_tax + payment_consumption_tax - published_point

      @report_data << row
    end
  end
end

