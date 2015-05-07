json.array!(@point_histories) do |point_history|
  json.extract! point_history, :id, :detail, :point_change, :created_at
end
