class AddPricePaymentPointToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :price, :integer, null: false, default: 0
    add_column :campaigns, :payment, :integer, null: false, default: 0
    add_column :campaigns, :point, :integer

    change_column_null :campaigns, :name, false
  end
end
