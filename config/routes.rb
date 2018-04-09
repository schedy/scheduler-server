Rails.application.routes.draw do

	resources :workers, only: [] do
		resources :status, only: [:create], controller: 'worker_statuses'
		resources :tasks, only: [] do
#			member do
				resources :status, only: [:create], controller: 'task_statuses'
#			end
		end
	end

	resources :resources, only: [:index] do
		collection do
			resources :statuses, only: [:create], controller: 'resource_statuses'
		end
	end

	resources :executions, only: [:create, :show] do
		resources :status, only: [:create], controller: 'execution_statuses'
		resources :artifacts, only: [:create], controller: 'artifacts' do
			collection do
				get '*path' => 'artifacts#show', constraints: { path: /.*/ }
			end
		end
		collection do
			post 'create/:hook(.format)' => 'executions#create'
		end
		member do
			post 'duplicate' => 'executions#duplicate'
		end
	end

	resources :tasks, only: [] do
		resources :status, only: [:create], controller: 'task_statuses'
		resources :tags, only: [:create], controller: 'task_values'
		resources :artifacts, only: [:create], controller: 'artifacts' do
			collection do
				get '*path' => 'artifacts#show', constraints: { path: /.*/ }
			end
		end
	end

	get 'a/(*whatever)' => 'application#index',  constraints: { whatever: /.*/ }
	root 'application#index'

end
