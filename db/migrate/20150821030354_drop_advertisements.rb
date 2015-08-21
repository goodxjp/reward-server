class DropAdvertisements < ActiveRecord::Migration
  def change
    drop_table :advertisements
  end
end
