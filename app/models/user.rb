class User < ActiveRecord::Base
	has_many :kills
	has_many :memberships
	has_many :neutralizations
	
	has_many :teams, through: :memberships

	has_secure_password

	validates :password, confirmation: true, presence: true, on: :create
	validates :email, :name, :phone_number, :address, :graduation_year, :profile_picture_url, :willing_to_pay_amount, presence: true
	validates :email, uniqueness: true, email_format: { message: "is not valid" }
	validates :graduation_year, numericality: { greater_than_or_equal_to: Date.today.year, less_than_or_equal_to: Date.today.year + 4 }
	validates :phone_number, format: { with: /\d{3}-\d{3}-\d{4}|\d{3}-\d{4}/, message: "has an incorrect format" }
end
