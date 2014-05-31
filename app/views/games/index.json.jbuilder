json.array!(@games) do |game|
  json.extract! game, :id, :name, :in_progress
  json.url game_url(game, format: :json)
end
