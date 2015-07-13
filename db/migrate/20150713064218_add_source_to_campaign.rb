class AddSourceToCampaign < ActiveRecord::Migration
  def change
    add_reference :campaigns, :campaign_source, index: true
    add_column :campaigns, :source_campaign_identifier, :string, index: true
    add_reference :campaigns, :source, polymorphic: true, index: true
  end
end
