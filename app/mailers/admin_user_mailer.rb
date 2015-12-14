# -*- coding: utf-8 -*-
class AdminUserMailer < ActionMailer::Base
  default from: "noreply@reward.com"
  add_template_helper(ApplicationHelper)

  def report_get_gree(create_gree_campaigns, delete_gree_campaigns)
    @create_gree_campaigns = create_gree_campaigns
    @delete_gree_campaigns = delete_gree_campaigns

    if staging?
      subject = "[Staging] Report GREE Ads Reward"
    else
      subject = "Report GREE Ads Reward"
    end
    mail to: "kyuuki0@gmail.com", subject: subject
  end

  def staging?
    if (ENV['NEW_RELIC_APP_NAME'] == 'reward-staging')
      true
    else
      false
    end
  end
end
