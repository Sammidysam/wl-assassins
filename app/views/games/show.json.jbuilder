json.extract! @game, :id, :name, :in_progress, :team_fee, :created_at, :updated_at
json.extract!(@game, :started_at) unless @game.started_at.nil?
json.extract!(@game, :ended_at) unless @game.ended_at.nil?
