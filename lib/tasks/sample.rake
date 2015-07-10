require 'factory_girl'

namespace :sample do
  desc "Add many sample data"
  task :add_data => :environment do
    Dir[Rails.root.join('spec/factories/*.rb')].each { |f| require f }
    ActiveRecord::Base.transaction do
      (1..10).each do |i|
        campaign = FactoryGirl.create(:campaign, name: "テスト案件 #{i}")
      end
    end
  end
end