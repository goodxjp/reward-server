json.array!(@campaigns) do |campaign|
  json.extract! campaign, :id, :name, :detail, :icon_url
  json.url campaign_url(campaign, format: :json)
end
