module ApplicationHelper
	def current_user
		User.find(session["current_user_id"]) if session["current_user_id"]
	end

	def title(title_string)
		content_for :title, title_string.to_s
	end

	def markdown(content)
		Markdown::RENDERER.render(content).html_safe
	end
end
