class Neutralization < ActiveRecord::Base
	belongs_to :game
	belongs_to :killer, class_name: "User"
	belongs_to :target, class_name: "User"
end
