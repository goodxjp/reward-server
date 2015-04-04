class AddNetworkToCampaigns < ActiveRecord::Migration
  def change
    add_reference :campaigns, :network, index: true
  end
end
