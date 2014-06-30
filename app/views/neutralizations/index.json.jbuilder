json.array!(@neutralizations) do |neutralization|
	json.extract! neutralization, :id, :confirmed, :killer_id, :target_id, :game_id
	json.extract!(neutralization, :start) unless neutralization.start.nil?
	json.extract!(neutralization, :how) unless neutralization.how.nil?
	json.extract!(neutralization, :picture_url) unless neutralization.picture_url.nil?
	json.url neutralization_url(neutralization, format: :json)
end
