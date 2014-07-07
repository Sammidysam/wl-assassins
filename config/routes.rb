WlAssassins::Application.routes.draw do
	get "dashboard" => "dashboard#index"
	get "history" => "games#index"
	get "log_in" => "session#new"
	get "log_out" => "session#destroy"
	get "welcome/index"
	
	post "session/create" => "session#create"
	post "session/new"
	
	resources :pages

	resources :neutralizations do
		post "confirm", on: :member
	end

	resources :kills do
		post "confirm", on: :member
	end
	
	resources :games do
		get "events", on: :member
		get "team_fees", on: :member
		
		post "add", on: :member
		post "remove", on: :member
		post "add_all", on: :member
		post "remove_all", on: :member
		post "start", on: :member
	end

	resources :teams do
		post "add", on: :member
		post "remove", on: :member
		post "terminators", on: :member
		post "revive", on: :member
		post "reset_termination_at", on: :member
		post "reset_out_of_town_hours", on: :member
	end
	
	resources :users do
		post "out_of_town", on: :member
		post "revive", on: :member
	end
	
	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	# You can have the root of your site routed with "root"
	root "welcome#index"

	# Example of regular route:
	#   get "products/:id" => "catalog#view"

	# Example of named route that can be invoked with purchase_url(id: product.id)
	#   get "products/:id/purchase" => "catalog#purchase", as: :purchase

	# Example resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Example resource route with options:
	#   resources :products do
	#     member do
	#       get "short"
	#       post "toggle"
	#     end
	#
	#     collection do
	#       get "sold"
	#     end
	#   end

	# Example resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Example resource route with more complex sub-resources:
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get "recent", on: :collection
	#     end
	#   end

	# Example resource route with concerns:
	#   concern :toggleable do
	#     post "toggle"
	#   end
	#   resources :posts, concerns: :toggleable
	#   resources :photos, concerns: :toggleable

	# Example resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end
end
