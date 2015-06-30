# -*- coding: utf-8 -*-
class Item < ActiveRecord::Base
  has_many :gifts

  validates :name, :presence => true
  validates :point,
    :presence => true,
    :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }

  # TODO: あとでキャッシュを使う
  def gifts_count
    return gifts.where(purchase: nil).size
  end
end
