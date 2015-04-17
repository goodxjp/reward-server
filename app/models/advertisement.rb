# -*- coding: utf-8 -*-
class Advertisement < ActiveRecord::Base
  belongs_to :campaign

  # ユーザーに意識させない
  #validates :campaigns, :presence => true
  validates :price,
    :presence => true,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :payment,
    :presence => true,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :point,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 },
    :allow_nil => true
end
