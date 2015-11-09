# -*- coding: utf-8 -*-
module ApplicationHelper
  def system_title
    if production?
      "リワードシステム"
    elsif staging?
      "(S) リワードシステム"
    else
      "(開) リワードシステム"
    end
  end

  def system_name
    if production?
      "リワードシステム"
    elsif staging?
      "リワードシステム (S)"
    else
      "リワードシステム (開)"
    end
  end

  def skin_color
    # https://www.almsaeedstudio.com/themes/AdminLTE/documentation/index.html#layout
    if production?
      "skin-purple"
    elsif staging?
      "skin-blue"
    else
      "skin-black"
    end
  end

  def production?
    if (ENV['NEW_RELIC_APP_NAME'] == 'reward-production')
      true
    else
      false
    end
  end

  def staging?
    if (ENV['NEW_RELIC_APP_NAME'] == 'reward-staging')
      true
    else
      false
    end
  end

  def development?
    if (ENV['RACK_ENV'] == 'development')
      true
    else
      false
    end
  end
end
