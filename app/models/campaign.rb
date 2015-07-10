class Campaign < ActiveRecord::Base
  belongs_to :network
  belongs_to :campaign_category
  has_many :advertisements

  has_many :points, :as => :source

  has_and_belongs_to_many :media

  validates :name, :presence => true
  validates :network, :presence => true
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
