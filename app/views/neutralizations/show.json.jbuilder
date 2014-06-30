json.extract! @neutralization, :id, :confirmed, :killer_id, :target_id, :game_id, :created_at, :updated_at
json.extract!(@neutralization, :start) unless @neutralization.start.nil?
json.extract!(@neutralization, :how) unless @neutralization.how.nil?
json.extract!(@neutralization, :picture_url) unless @neutralization.picture_url.nil?
