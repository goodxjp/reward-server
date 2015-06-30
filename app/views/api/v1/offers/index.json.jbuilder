json.array!(@offers) do |offer|
  json.extract! offer, :id, :campaign_id, :campaign_category_id, :name, :detail, :icon_url, :requirement, :requirement_detail, :period, :price, :point
  json.execute_url make_execute_url(offer, @medium.id, @media_user.id)
  #json.url offer_url(offer, format: :json)
end
