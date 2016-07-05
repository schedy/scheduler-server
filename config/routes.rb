Rails.application.routes.draw do


	resources :artifacts, only: [:create] do
		member do
			get ':filename' => 'artifacts#show'
		end
	end

	resources :workers, only: [] do
		member do
			post 'status' => 'worker_statuses#create'
		end
	end

	resources :resources, only: [] do
		member do
			post 'status' => 'worker_statuses#create'
		end
	end


  get '/executions/duplicate' => 'executions#duplicate'
  get '/executions/force_status' => 'executions#force_status'
	resources :executions

	resources :execution_statuses, only: [:create]
	resources :task_statuses, only: [:create]
	resources :task_values, only: [:create]
	resources :resource_statuses, only: [:create]

	get 'a/(*whatever)' => 'application#index',  constraints: { whatever: /.*/ }
	root 'application#index'


	#resources :tasks, only: [] do
	#	member do
	#		post 'artifacts' => 'artifacts#create'
	#	end
	#end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
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
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
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
