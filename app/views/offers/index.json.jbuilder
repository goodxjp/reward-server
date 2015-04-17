json.array!(@offers) do |offer|
  json.extract! offer, :id, :campaign_id, :campaign_category, :name, :detail, :icon_url, :url, :requirement, :requirement_detail, :period, :price, :point
  #json.url offer_url(offer, format: :json)
end
