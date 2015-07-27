# -*- coding: utf-8 -*-
class NetworkSystem < ActiveHash::Base
  # http://labs.timedia.co.jp/2014/01/activehashrails.html
  include ActiveHash::Enum

  self.data = [
    { id: 1, network_system: "ADCROPS", name: "adcrops" },
    { id: 2, network_system: "GREE", name: "GREE Ads Reward" },
  ]

  enum_accessor :network_system
end
