class Page < ActiveRecord::Base
	validates :name, presence: true
	validates :name, :sort_index, uniqueness: true
end
