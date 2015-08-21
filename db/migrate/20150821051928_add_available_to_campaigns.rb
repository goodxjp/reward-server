class AddAvailableToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :available, :boolean, null: false, default: true
  end
end
