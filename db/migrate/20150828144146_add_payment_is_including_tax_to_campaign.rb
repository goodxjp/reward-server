class AddPaymentIsIncludingTaxToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :payment_is_including_tax, :boolean,  null: false, default: false
  end
end
