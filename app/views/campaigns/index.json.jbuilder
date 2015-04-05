json.array!(@campaigns) do |campaign|
  json.extract! campaign, :id, :name, :detail, :icon_url
  json.url execute_campaign_url(campaign)
  json.point campaign.advertisements[0].point
end
