json.extract! @kill, :id, :confirmed, :target_id, :kind, :game_id, :killer_id, :created_at, :updated_at
json.extract!(@kill, :confirmed_at) unless @kill.confirmed_at.nil?
json.extract!(@kill, :picture_url) unless @kill.picture_url.nil?
json.extract!(@kill, :how) unless @kill.how.nil?
