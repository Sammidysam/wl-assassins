class Participation < ActiveRecord::Base
	belongs_to :game
	belongs_to :team

	has_many :contracts
	has_many :kills
end
