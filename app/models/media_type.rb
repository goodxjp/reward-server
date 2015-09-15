# -*- coding: utf-8 -*-
class MediaType < ActiveHash::Base
  # http://labs.timedia.co.jp/2014/01/activehashrails.html
  include ActiveHash::Enum

  self.data = [
    { id: 1, media_type: "Android", name: "Android" },
    { id: 2, media_type: "Ios", name: "iOS" },
  ]

  enum_accessor :media_type
end
