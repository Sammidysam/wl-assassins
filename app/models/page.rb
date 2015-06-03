class Page < ActiveRecord::Base
	validates :name, presence: true, uniqueness: true, length: { maximum: 255 }
	validates :sort_index, uniqueness: true, allow_nil: true
	validates :link, length: { maximum: 255 }

	nilify_blanks
end
