class Page < ActiveRecord::Base
	validates :name, presence: true
end
