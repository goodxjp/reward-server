require 'factory_girl'

namespace :sample do
  desc "Add many sample data"
  task :add_data => :environment do
#    Dir[Rails.root.join('spec/factories/*.rb')].each { |f| require f }
# なぜか、このコードで FactoryGirl::DuplicateDefinitionError: Factory already registered: point_history が発生するようになった。

    medium = Medium.find(1)
    network = Network.find(1)
    campaign_source = CampaignSource.find(1)
    ActiveRecord::Base.transaction do
      (1..10).each do |i|
        media_user = FactoryGirl.create(:media_user, medium: medium, terminal_id: "terminalxidy#{i}")
      end

      (1..10).each do |i|
        campaign = FactoryGirl.create(:campaign, network: network, campaign_source: campaign_source, name: "テスト案件 #{i}")
      end
    end
  end
end
