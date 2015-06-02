# -*- coding: utf-8 -*-
class Gift < ActiveRecord::Base
  belongs_to :item
  belongs_to :purchase

  validates :code,
    presence: true,
    uniqueness: true,
    length: { minimum: 10, matimum: 30 },  # ギフト券番号の仕様要調査
    format: { with: /\A[0-9A-Z\-]+\z/ }
  # TODO: 日付の検証
end
