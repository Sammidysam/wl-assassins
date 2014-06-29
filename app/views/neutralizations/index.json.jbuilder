json.array!(@neutralizations) do |neutralization|
  json.extract! neutralization, :id, :confirmed, :start, :killer_id, :target_id, :game_id, :how, :picture_url
  json.url neutralization_url(neutralization, format: :json)
end
