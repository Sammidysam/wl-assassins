class Game < ActiveRecord::Base
	has_many :neutralizations
	has_many :participations
	
	has_many :contracts, through: :participations
	has_many :kills, through: :participations
	has_many :teams, through: :participations
end
