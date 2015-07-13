class RemoveNetworkFromCampaign < ActiveRecord::Migration
  def change
    remove_column :campaigns, :network_id, :integer
  end
end
