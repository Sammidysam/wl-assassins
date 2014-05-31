json.array!(@teams) do |team|
  json.extract! team, :id, :name, :description
  json.url team_url(team, format: :json)
end
