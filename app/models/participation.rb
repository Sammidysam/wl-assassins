class Participation < ActiveRecord::Base
	belongs_to :game
	belongs_to :team

	has_many :contracts, dependent: :destroy
	has_many :kills, dependent: :destroy

	validates :team_id, :game_id, :paid_amount, presence: true
end
