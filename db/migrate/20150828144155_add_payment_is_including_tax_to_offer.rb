class AddPaymentIsIncludingTaxToOffer < ActiveRecord::Migration
  def change
    add_column :offers, :payment_is_including_tax, :boolean, null: false, default: false
  end
end
