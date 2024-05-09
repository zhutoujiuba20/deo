Rails.application.routes.draw do
  # admin
  namespace :admin do
    resources :system_configs
    resources :users do
      get :export, on: :collection
    end
    resources :comments
    resources :discussions
    resources :system_api_keys
    resources :tags
    resources :organizations
    resources :error_logs
    resources :models, except: [:new, :create]
    resources :datasets, except: [:new, :create]

    root to: "users#index"
  end

  # internal api
  namespace :internal_api do
    resources :organizations, only: [:create, :update] do
      collection do
        post '/new-members', to: 'organizations#new_members'
      end
      member do
        get '/members', to: 'organizations#members'
        delete '/members/:user_id', to: 'organizations#remove_member'
        put '/members/:user_id', to: 'organizations#update_member'
      end
    end
    resources :comments, only: [:create, :destroy, :index]
    resources :ssh_keys, only: [:create, :destroy]
    resources :git_token, only: [] do
      collection do
        post 'refresh', to: 'git-tokens/refresh'
      end
    end
    resources :users, only: [:index, :update] do
      collection do
        put 'jwt_token', to: 'users/jwt_token'
      end
    end
    get '/users/:namespace/models', to: 'users#models'
    get '/users/:namespace/datasets', to: 'users#datasets'
    get '/users/:namespace/codes', to: 'users#codes'
    get '/users/:namespace/spaces', to: 'users#spaces'
    get '/users/:namespace/likes/:repo_type', to: 'users#likes_repo'
    put '/users/likes/:repo_id', to: 'users#add_like'
    delete '/users/likes/:repo_id', to: 'users#delete_like'
    get '/organizations/:namespace/models', to: 'organizations#models'
    get '/organizations/:namespace/datasets', to: 'organizations#datasets'
    get '/organizations/:namespace/codes', to: 'organizations#codes'
    get '/organizations/:namespace/spaces', to: 'organizations#spaces'

    resources :models, only: [:index, :create]
    get '/models/:namespace/(*model_name)/readme', to: 'models#readme'
    get '/models/:namespace/(*model_name)/files', to: 'models#files'
    post '/models/:namespace/(*model_name)/files/:branch', to: 'models#create_file'
    post '/models/:namespace/(*model_name)/files/:branch/upload_file', to: 'models#upload_file'
    put '/models/:namespace/(*model_name)/files/:branch', to: 'models#update_file'
    put '/models/:namespace/(*model_name)/update_readme_tags', to: 'models#update_readme_tags'
    delete '/models/:namespace/(*model_name)', to: 'models#destroy', format: false, defaults: {format: 'html'}
    put '/models/:namespace/(*model_name)', to: 'models#update', format: false, defaults: {format: 'html'}
    post '/models/:namespace/(*model_name)/predict', to: 'models#predict'
    get '/models/:namespace/(*model_name)/related_repos', to: 'models#related_repos'

    resources :datasets, only: [:index, :create]
    get '/datasets/:namespace/(*dataset_name)/readme', to: 'datasets#readme'
    get '/datasets/:namespace/(*dataset_name)/files', to: 'datasets#files'
    get '/datasets/:namespace/(*dataset_name)/preview', to: 'datasets#preview_parquet'
    post '/datasets/:namespace/(*dataset_name)/files/:branch', to: 'datasets#create_file'
    post '/datasets/:namespace/(*dataset_name)/files/:branch/upload_file', to: 'datasets#upload_file'
    put '/datasets/:namespace/(*dataset_name)/files/:branch', to: 'datasets#update_file'
    put '/datasets/:namespace/(*dataset_name)/update_readme_tags', to: 'datasets#update_readme_tags'
    delete '/datasets/:namespace/(*dataset_name)', to: 'datasets#destroy', format: false, defaults: {format: 'html'}
    put '/datasets/:namespace/(*dataset_name)', to: 'datasets#update', format: false, defaults: {format: 'html'}
    get '/datasets/:namespace/(*dataset_name)/related_repos', to: 'datasets#related_repos'

    resources :codes, only: [:index, :create]
    get '/codes/:namespace/(*code_name)/readme', to: 'codes#readme'
    get '/codes/:namespace/(*code_name)/files', to: 'codes#files'
    post '/codes/:namespace/(*code_name)/files/:branch', to: 'codes#create_file'
    post '/codes/:namespace/(*code_name)/files/:branch/upload_file', to: 'codes#upload_file'
    put '/codes/:namespace/(*code_name)/files/:branch', to: 'codes#update_file'
    delete '/codes/:namespace/(*code_name)', to: 'codes#destroy', format: false, defaults: {format: 'html'}
    put '/codes/:namespace/(*code_name)', to: 'codes#update', format: false, defaults: {format: 'html'}
    get '/codes/:namespace/(*code_name)/related_repos', to: 'codes#related_repos'

    resources :spaces, controller: 'application_spaces', only: [:index, :create]
    get '/spaces/:namespace/(*application_space_name)/readme', to: 'application_spaces#readme'
    get '/spaces/:namespace/(*application_space_name)/files', to: 'application_spaces#files'
    post '/spaces/:namespace/(*application_space_name)/files/:branch', to: 'application_spaces#create_file'
    post '/spaces/:namespace/(*application_space_name)/files/:branch/upload_file', to: 'application_spaces#upload_file'
    put '/spaces/:namespace/(*application_space_name)/files/:branch', to: 'application_spaces#update_file'
    delete '/spaces/:namespace/(*application_space_name)', to: 'application_spaces#destroy', format: false, defaults: {format: 'html'}
    put '/spaces/:namespace/(*application_space_name)', to: 'application_spaces#update', format: false, defaults: {format: 'html'}

    resources :tags, only: [] do
      collection do
        get 'task-tags', to: 'tags#task_tags'
        get 'framework-tags', to: 'tags#framework_tags'
        get 'language-tags', to: 'tags#language_tags'
      end
    end
    # resources :discussions, only: :create
    resources :discussions, only: [:create, :index, :update]
    resources :upload, only: [:create]
  end

  # application
  scope "(:locale)", :locale => /en|zh/ do
    root "models#index"

    resources :settings, only: [] do
      collection do
        get 'profile'
        get 'git-token'
        get 'ssh-keys'
        get 'locale'
      end
    end

    resources :models, only: [:index, :new]
    resources :datasets, only: [:index, :new]
    resources :codes, only: [:index, :new]
    resources :spaces, controller: 'application_spaces', only: [:index, :new]
    resources :organizations, only: [:new, :show, :edit] do
      member do
        get 'members'
      end
    end
    get '/models/:namespace/(*model_name)/:branch/new', to: 'models#new_file'
    get '/models/:namespace/(*model_name)/edit/:branch/(*path)', to: 'models#edit_file', format: false, defaults: {format: 'html'}
    get '/models/:namespace/(*model_name)/:branch/upload', to: 'models#upload_file'
    get '/models/:namespace/(*model_name)/blob/:branch/(*path)', to: 'models#blob', format: false, defaults: {format: 'html'}
    get '/models/:namespace/(*model_name)/files/:branch(/*path)', to: 'models#files', defaults: { path: nil }
    get '/models/:namespace/(*model_name)/resolve/:branch/(*path)', to: 'models#resolve', defaults: {format: 'txt'}
    get '/models/:namespace/(*model_name)/community', to: 'models#community'
    get '/models/:namespace/(*model_name)/settings', to: 'models#settings'
    get '/models/:namespace/(*model_name)', to: 'models#show', format: false, defaults: {format: 'html'}

    get '/datasets/:namespace/(*dataset_name)/:branch/new', to: 'datasets#new_file'
    get '/datasets/:namespace/(*dataset_name)/edit/:branch/(*path)', to: 'datasets#edit_file', format: false, defaults: {format: 'html'}
    get '/datasets/:namespace/(*dataset_name)/:branch/upload', to: 'datasets#upload_file'
    get '/datasets/:namespace/(*dataset_name)/blob/:branch/(*path)', to: 'datasets#blob', format: false, defaults: {format: 'html'}
    get '/datasets/:namespace/(*dataset_name)/files/:branch(/*path)', to: 'datasets#files', defaults: { path: nil }
    get '/datasets/:namespace/(*dataset_name)/resolve/:branch/(*path)', to: 'datasets#resolve', defaults: {format: 'txt'}
    get '/datasets/:namespace/(*dataset_name)/community', to: 'datasets#community'
    get '/datasets/:namespace/(*dataset_name)/settings', to: 'datasets#settings'
    get '/datasets/:namespace/(*dataset_name)', to: 'datasets#show', format: false, defaults: {format: 'html'}

    get '/codes/:namespace/(*code_name)/:branch/new', to: 'codes#new_file'
    get '/codes/:namespace/(*code_name)/edit/:branch/(*path)', to: 'codes#edit_file', format: false, defaults: {format: 'html'}
    get '/codes/:namespace/(*code_name)/:branch/upload', to: 'codes#upload_file'
    get '/codes/:namespace/(*code_name)/blob/:branch/(*path)', to: 'codes#blob', format: false, defaults: {format: 'html'}
    get '/codes/:namespace/(*code_name)/files/:branch(/*path)', to: 'codes#files', defaults: { path: nil }
    get '/codes/:namespace/(*code_name)/resolve/:branch/(*path)', to: 'codes#resolve', defaults: {format: 'txt'}
    get '/codes/:namespace/(*code_name)/community', to: 'codes#community'
    get '/codes/:namespace/(*code_name)/settings', to: 'codes#settings'
    get '/codes/:namespace/(*code_name)', to: 'codes#show', format: false, defaults: {format: 'html'}

    get '/spaces/:namespace/(*application_space_name)/:branch/new', to: 'application_spaces#new_file'
    get '/spaces/:namespace/(*application_space_name)/edit/:branch/(*path)', to: 'application_spaces#edit_file', format: false, defaults: {format: 'html'}
    get '/spaces/:namespace/(*application_space_name)/:branch/upload', to: 'application_spaces#upload_file'
    get '/spaces/:namespace/(*application_space_name)/blob/:branch/(*path)', to: 'application_spaces#blob', format: false, defaults: {format: 'html'}
    get '/spaces/:namespace/(*application_space_name)/files/:branch(/*path)', to: 'application_spaces#files', defaults: { path: nil }
    get '/spaces/:namespace/(*application_space_name)/resolve/:branch/(*path)', to: 'application_spaces#resolve', defaults: {format: 'txt'}
    get '/spaces/:namespace/(*application_space_name)/community', to: 'application_spaces#community'
    get '/spaces/:namespace/(*application_space_name)/settings', to: 'application_spaces#settings'
    get '/spaces/:namespace/(*application_space_name)', to: 'application_spaces#show', format: false, defaults: {format: 'html'}

    get '/profile/:user_id', to: 'profile#index'
    get '/profile/likes/:user_id', to: 'profile#likes'
    get    '/signup', to: 'sessions#signup'
    get    '/login', to: 'sessions#new'
    get    '/oidc/callback', to: 'sessions#oidc'
    post   '/login',   to: 'sessions#create'
    post   '/signup',   to: 'sessions#registration'
    delete '/logout',  to: 'sessions#destroy'
    get    '/logout',  to: 'sessions#destroy'

    # errors
    get '/errors/not-found', to: 'errors#not_found'
    get '/errors/unauthorized', to: 'errors#unauthorized'
  end
end
