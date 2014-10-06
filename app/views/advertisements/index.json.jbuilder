json.array!(@advertisements) do |advertisement|
  json.extract! advertisement, :id, :campaigns_id, :price, :payment, :point
  json.url advertisement_url(advertisement, format: :json)
end
