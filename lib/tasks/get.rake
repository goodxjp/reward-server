require 'nokogiri'
require 'open-uri'
require 'kconv'

namespace :get do
  desc "Get au SmartPass data from RewardPlatform (for Sample)"
  task :au => :environment do
    uri = URI("http://rewardplatform.jp/goldtaro/210141/")
    user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12A365 Safari/600.1.4"

    html = open(uri, 'User-Agent' => user_agent, &:read).toutf8
    File.write(Rails.root.join('aaa.html'), html)

    doc = Nokogiri.HTML(html)

    ActiveRecord::Base.transaction do
      doc.xpath("//div[@class='item_info']").each do |node|
        h3 = node.css("h3").first.content
        img_src = node.css("img").first['src']
        inst_href = node.css(".inst a").first['href']
        id = inst_href.scan(/\?c=([0-9]+)&/)[0][0].to_i

        puts h3
        puts img_src
        puts inst_href
        puts id

        campaigns = Campaign.where(campaign_source_id: 1, source_campaign_identifier: id.to_s)

        if (campaigns.size == 0)
          campaign = Campaign.new
        else
          campaign = campaigns[0]
        end

        campaign.network_id = 2
        campaign.campaign_source_id = 1
        campaign.source_campaign_identifier = id

        campaign.campaign_category_id = 2
        campaign.name = h3
        campaign.icon_url = "http://rewardplatform.jp/#{img_src}"
        campaign.url = inst_href
        campaign.price = 0
        campaign.payment = id % 1234

        campaign.available = true
        campaign.save!
      end
    end
  end
end
