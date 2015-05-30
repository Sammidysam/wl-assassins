namespace :started_at do
	task :fill_in => :environment do
		# We will assume the last update was accepting the invitation.
		Membership.all.each do |m|
			if !m.started_at && !m.ended_at
				m.started_at = m.updated_at
			else
				m.started_at = m.created_at
			end
			m.save
		end
	end
end
