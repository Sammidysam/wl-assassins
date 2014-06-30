json.extract! @team, :id, :name, :created_at, :updated_at
json.extract!(@team, :description) unless @team.description.nil?
json.extract!(@team, :logo_url) unless @team.logo_url.nil?
