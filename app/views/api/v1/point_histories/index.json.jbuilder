json.array!(@point_histories) do |point_history|
  json.extract! point_history, :id, :detail, :point_change, :occurred_at, :created_at
end
