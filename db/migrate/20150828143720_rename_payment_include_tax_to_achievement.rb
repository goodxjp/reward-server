class RenamePaymentIncludeTaxToAchievement < ActiveRecord::Migration
  def change
    rename_column :achievements, :payment_include_tax, :payment_is_including_tax
  end
end
