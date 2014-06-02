class User < ActiveRecord::Base
	has_many :kills
	has_many :memberships
	has_many :neutralizations
	has_many :teams, through: :memberships
end
