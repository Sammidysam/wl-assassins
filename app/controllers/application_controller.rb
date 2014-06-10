class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	# Allow users to be created.
	before_filter do
		resource = controller_name.singularize.to_sym
		method = "#{resource}_params"
		params[resource] &&= send(method) if respond_to?(method, true)
	end

	rescue_from CanCan::AccessDenied do |error|
		redirect_to root_url, alert: error.message
	end

	# Call the helper current_user method.
	def current_user
		view_context.current_user
	end
end
