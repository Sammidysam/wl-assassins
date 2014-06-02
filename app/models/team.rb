class Team < ActiveRecord::Base
	has_many :games, through: :participations
	has_many :memberships
	has_many :participations
	has_many :users, through: :memberships
end
