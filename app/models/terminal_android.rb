class TerminalAndroid < ActiveRecord::Base
  belongs_to :media_user

  #
  # Validation
  #
  validates :identifier,
    presence: true
end
