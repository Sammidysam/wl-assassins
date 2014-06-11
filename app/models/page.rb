class Page < ActiveRecord::Base
	nilify_blanks
	
	validates :name, presence: true
	validates :name, :sort_index, uniqueness: true
end
