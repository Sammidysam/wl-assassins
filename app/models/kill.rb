class Kill < ActiveRecord::Base
	belongs_to :participation
	
	belongs_to :target, class_name: "User"
end
