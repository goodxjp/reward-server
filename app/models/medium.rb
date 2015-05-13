class Medium < ActiveRecord::Base
  has_and_belongs_to_many :campaigns

  validates :name,
    :presence => true
  validates :key,
    :presence => true,
    :format => { :with => /\A[0-9A-Za-z]+\z/ }

end
