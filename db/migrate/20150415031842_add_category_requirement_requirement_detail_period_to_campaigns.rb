class AddCategoryRequirementRequirementDetailPeriodToCampaigns < ActiveRecord::Migration
  def change
    add_reference :campaigns, :campaign_category, index: true
    add_column :campaigns, :requirement, :string
    add_column :campaigns, :requirement_detail, :text
    add_column :campaigns, :period, :string
  end
end
