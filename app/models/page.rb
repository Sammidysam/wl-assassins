class Page < ActiveRecord::Base
	before_validation do
		self.link = nil if self.link && self.link.empty?
	end
	
	validates :name, presence: true
	validates :name, :sort_index, uniqueness: true
end
