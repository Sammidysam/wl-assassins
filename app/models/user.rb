class User < ActiveRecord::Base
	enum role: [ :normal, :public_admin, :private_admin ]
	
	has_many :memberships, dependent: :destroy
	
	has_many :teams, through: :memberships

	has_secure_password
	
	validates :password, confirmation: true, presence: true, on: :create
	validates :email, :name, :phone_number, :address, :graduation_year, :profile_picture_url, :willing_to_pay_amount, :description, presence: true
	validates :email, uniqueness: true, email_format: { message: "is not valid" }
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
		in_game? ? Kill.where(participation_id: team.participation.id, target_id: self.id, confirmed: true).empty? : true
	end

	def dead?
		!alive?
	end

	def terminator?
		team.terminators?
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
end
