class AddNetworkSystemToCampaignSource < ActiveRecord::Migration
  def change
    add_column :campaign_sources, :network_system_id, :integer
  end
end
