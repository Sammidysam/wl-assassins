class User < ActiveRecord::Base
	include ActionView::Helpers::TextHelper

	enum role: [ :normal, :public_admin, :private_admin ]

	has_many :kills, foreign_key: "target_id", dependent: :destroy
	has_many :memberships, dependent: :destroy
	has_many :target_neutralizations, class_name: "Neutralization", foreign_key: "target_id", dependent: :destroy
	has_many :killer_neutralizations, class_name: "Neutralization", foreign_key: "killer_id", dependent: :destroy
	has_many :teams, through: :memberships

	has_secure_password

	validates :password, confirmation: true, presence: true, on: :create
	validates :email, :name, :phone_number, :address, :graduation_year, :profile_picture_url, :willing_to_pay_amount, :description, presence: true
	validates :email, uniqueness: { case_sensitive: false }, email_format: { message: "is not a real email" }
	validates :phone_number, format: { with: /\d{3}-\d{3}-\d{4}|\d{3}-\d{4}/, message: "has an incorrect format" }
	validates :name, :email, :password_digest, :phone_number, :address, :profile_picture_url, length: { maximum: 255 }

	# If the user is eligible to play.
	def eligible?
		year = DateTime.now.year
		self.graduation_year >= year && self.graduation_year <= year + 3
	end

	# Returns if the user is an admin.
	def admin?
		self.public_admin? || self.private_admin?
	end

	def in_game?
		team.in_game? if team
	end

	def alive?(game_id = (team && team.participation ? team.participation.game_id : nil))
		kill(game_id).nil?
	end

	def dead?(game_id = (team && team.participation ? team.participation.game_id : nil))
		!alive?(game_id)
	end

	# Returns the kill that killed this user.
	def kill(game_id = (team && team.participation ? team.participation.game_id : nil))
		Kill.find_by game_id: game_id, target_id: self.id, confirmed: true
	end

	def neutralized?
		!self.killer_neutralizations.where(game_id: team.participation.game_id, confirmed: true).select { |neutralization| DateTime.now < neutralization.end_time }.empty? if in_game? && alive?
	end

	def neutralized_end
		self.killer_neutralizations.where(game_id: team.participation.game_id, confirmed: true).order(:start).select { |neutralization| DateTime.now < neutralization.end_time }.last.end_time
	end

	def terminator?
		team.terminators? if team
	end

	# Returns the current team for the user.
	# game_id being present returns the team this user was on during that game.
	def team(game_id = nil)
		memberships = self.memberships

		if game_id
			game = Game.find(game_id)
			created_before = memberships.where("started_at < ?", game.started_at)
			(created_before.where(ended_at: nil) + created_before.where("ended_at > ?", game.ended_at)).first.team
		else
			membership = memberships.find { |m| m.active? }

			membership.team if membership
		end
	end

	# Returns true if the user is on the given team.
	def on_team?(team)
		if team.is_a?(Team)
			self.team.id == team.id
		else
			team.map(&:id).include?(self.team.id)
		end
	end

	def autoterminate
		kill = Kill.new
		kill.target_id = self.id
		kill.kind = "out_of_time"
		kill.game_id = team.participation.game_id
		kill.appear_at = team.participation.termination_at

		kill.save
	end

	def autoterminations
		kills.out_of_time.where(confirmed: false, game_id: team.participation.game_id).where.not(appear_at: nil)
	end

	def remove_autotermination
		autoterminations.destroy_all
	end

	def out_of_town_kills
		kills.out_of_town.where(confirmed: false, game_id: team.participation.game_id).where.not(appear_at: nil)
	end

	def remove_out_of_town_kills
		out_of_town_kills.destroy_all
	end
end
