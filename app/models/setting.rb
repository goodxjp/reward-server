# -*- coding: utf-8 -*-
class Setting
  # 消費税
  def self.consumption_tax_rate(now)
    if now < Time.zone.local(2017, 4, 1, 0, 0, 0)  # この日まで消費税率 8%
      return 0.08
    else
      return 0.10
    end
  end

  # デフォルト還元率
  def self.reduction_rate(now)
    return 0.50
  end
end

