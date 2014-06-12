class Page < ActiveRecord::Base
	validates :name, presence: true, uniqueness: true
	validates :sort_index, uniqueness: true, allow_nil: true

	nilify_blanks
end
