class AddAvailableToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :available, :boolean, null: false, default: true
  end
end
