# -*- coding: utf-8 -*-
class PointType < ActiveHash::Base
  # http://labs.timedia.co.jp/2014/01/activehashrails.html
  include ActiveHash::Enum

  self.data = [
    { id: 1, point_type: "Manual", name: "手動" },
    { id: 2, point_type: "Auto", name: "自動" },
  ]

  enum_accessor :point_type
end
