json.array!(@kills) do |kill|
  json.extract! kill, :id, :confirmed, :target_id, :confirmed_at, :picture_url, :how, :kind, :game_id, :killer_id, :appear_at
  json.url kill_url(kill, format: :json)
end