# -*- coding: utf-8 -*-
class AdminUserMailer < ActionMailer::Base
  default from: "goodx.jp@gmail.com",
          to: "kyuuki0@gmail.com"
  add_template_helper(ApplicationHelper)  # 結局、意味なかったかも。

  def report_get_gree(create_gree_campaigns, delete_gree_campaigns)
    @create_gree_campaigns = create_gree_campaigns
    @delete_gree_campaigns = delete_gree_campaigns

    subject = "Report GREE Ads Reward Get"
    subject = "[Staging] #{subject}"if staging?

    mail subject: subject
  end

  def report_gree_check(report_messages)
    @report_messages = report_messages

    subject = "Report GREE Ads Reward Check"
    subject = "[Staging] #{subject}"if staging?

    mail subject: subject
  end

  def report_app_driver_get(create_ns_campaigns, delete_ns_campaigns)
    @create_ns_campaigns = create_ns_campaigns
    @delete_ns_campaigns = delete_ns_campaigns

    subject = "Report AppDriver Get"
    subject = "[Staging] #{subject}"if staging?

    mail subject: subject
  end

  # TODO: いろんな所で使うので、ユーティリティ化したい。
  def staging?
    if (ENV['NEW_RELIC_APP_NAME'] == 'reward-staging')
      true
    else
      false
    end
  end
end
