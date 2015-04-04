json.array!(@networks) do |network|
  json.extract! network, :id, :name
  json.url network_url(network, format: :json)
end
