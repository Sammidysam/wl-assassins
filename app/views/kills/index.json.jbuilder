json.array!(@kills) do |kill|
	json.extract! kill, :id, :confirmed, :target_id, :kind, :game_id, :killer_id
	json.extract!(kill, :confirmed_at) unless kill.confirmed_at.nil?
	json.extract!(kill, :picture_url) unless kill.picture_url.nil?
	json.extract!(kill, :how) unless kill.how.nil?
	json.url kill_url(kill, format: :json)
end
