json.array!(@items) do |item|
  json.extract! item, :id, :name, :point
  json.count item.gifts_count
end
