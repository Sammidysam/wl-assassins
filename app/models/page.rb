class Page < ActiveRecord::Base
	nilify_blanks
	
	validates :name, presence: true, uniqueness: true
	validates :sort_index, uniqueness: true, allow_nil: true
end
