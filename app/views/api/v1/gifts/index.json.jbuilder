json.array!(@gifts) do |gift|
  json.extract! gift, :code, :expiration_at, :created_at
  json.name gift.item.name
end
