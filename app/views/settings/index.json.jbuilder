json.array!(@configs) do |config|
  json.extract! config, :id
  json.url config_url(config, format: :json)
end
