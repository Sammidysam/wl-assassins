class Page < ActiveRecord::Base
	nilify_blanks except: :content
	
	validates :name, presence: true, uniqueness: true
	validates :sort_index, uniqueness: true, allow_nil: true
end
