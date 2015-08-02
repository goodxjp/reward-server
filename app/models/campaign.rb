# -*- coding: utf-8 -*-
class Campaign < ActiveRecord::Base
  # 売上先
  belongs_to :network

  # キャンペーンの入手経路 (ソース)
  belongs_to :campaign_source  # source のみで一意に決まりそうだが、手動で登録するときは source データがないこともあるので、このカラムは必須。
  belongs_to :source, polymorphic: true

  belongs_to :campaign_category

  has_many :achievements
  has_many :points, :as => :source

  has_and_belongs_to_many :media

  # Validations
  validates :campaign_source, :presence => true
  validates :name, :presence => true
  validates :url, :presence => true
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
