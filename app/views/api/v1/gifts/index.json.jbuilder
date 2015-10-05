json.array!(@gifts) do |gift|
  json.extract! gift, :code, :expiration_at
  json.occurred_at gift.purchase.occurred_at
  json.name gift.item.name
end
