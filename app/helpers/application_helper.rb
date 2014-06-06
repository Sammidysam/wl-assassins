module ApplicationHelper
	def current_user
		User.find(session[:user_id]) if session[:user_id]
	end

	def title(title_string)
		content_for :title, title_string.to_s
	end

	def markdown(content)
		Markdown::RENDERER.render(content).html_safe
	end
end
