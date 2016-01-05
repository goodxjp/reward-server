# -*- coding: utf-8 -*-
#
# ネットワークシステム
#
# - 会社名じゃなくシステムの名前がベター。
# - この継承先にネットワークシステムに関する情報を全て集約したい。
#   (新たなネットワークを追加するときにわかりやすいように)
#
class NetworkSystem < ActiveHash::Base
  # http://labs.timedia.co.jp/2014/01/activehashrails.html
  include ActiveHash::Enum

  self.data = [
    { id: 1, network_system: "ADCROPS", name: "adcrops" },
    { id: 2, network_system: "GREE", name: "GREE Ads Reward" },
    { id: 3, network_system: "APP_DRIVER", name: "AppDriver" },
  ]

  enum_accessor :network_system

  # TODO: ↓ここら辺、メタプログラムできれいにできないか。

  def get_concrete_class
    case self
    when NetworkSystem::GREE then
      NetworkSystemGree
    when NetworkSystem::APP_DRIVER then
      NetworkSystemAppDriver
    else
      nil
    end
  end

  def find_ns_campaign(ns_campaign_id)
    get_concrete_class.find_ns_campaign(ns_campaign_id)
  end
end
