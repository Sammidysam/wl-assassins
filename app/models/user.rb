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
	validates :email, uniqueness: { case_sensitive: false }, email_format: { message: "is not valid" }
	validates :graduation_year, numericality: { greater_than_or_equal_to: Date.today.year, less_than_or_equal_to: Date.today.year + 3 }
	validates :phone_number, format: { with: /\d{3}-\d{3}-\d{4}|\d{3}-\d{4}/, message: "has an incorrect format" }

	# Returns if the user is an admin.
	def admin?
		self.public_admin? || self.private_admin?
	end

	def in_game?
		team.in_game? if team
	end

	def alive?
		in_game? ? kill.nil? : true
	end

	def dead?
		!alive?
	end

	# Returns the kill that killed this user.
	def kill
		Kill.find_by game_id: team.participation.game_id, target_id: self.id, confirmed: true
	end

	def neutralized?
		!self.killer_neutralizations.where(game_id: team.participation.game_id, confirmed: true).select { |neutralization| DateTime.now < neutralization.end_time }.empty? if in_game? && alive?
	end

	def neutralized_end
		TimeDifference.between self.killer_neutralizations.where(game_id: team.participation.game_id, confirmed: true).order(:start).select { |neutralization| DateTime.now < neutralization.end_time }.last.end_time, Time.now
	end

	def neutralized_end_format
		components = []

		components << pluralize(neutralized_end.in_hours.floor, "hour") if neutralized_end.in_hours.floor > 0
		components << pluralize(neutralized_end.in_minutes.floor - neutralized_end.in_hours.floor * 60, "minute") if neutralized_end.in_minutes.floor > 0

		components.to_sentence
	end

	def terminator?
		team.terminators? if team
	end

	# Returns the current team for the user.
	def team
		membership = self.memberships.find_by active: true

		membership.team if membership
	end

	# Returns true if the user is on the given team.
	def on_team?(team)
		self.team.id == team.id
	end

	def autoterminate
		kill = Kill.new
		kill.target_id = self.id
		kill.kind = "out_of_time"
		kill.game_id = team.participation.game_id
		kill.appear_at = team.participation.termination_at

		kill.save
	end

	def remove_autotermination
		kills.out_of_time.where(confirmed: false, game_id: team.participation.game_id).where.not(appear_at: nil).destroy_all
	end
end
