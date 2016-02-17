Rails.application.routes.draw do

  ActiveAdmin.routes(self)
  # We remove the sign_up path name so as not to allow users to sign in with username and password.
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }, path_names: { sign_up: ''}

  root 'pages#index'

  # Tagging pages
  get '/tags/search/:search', to: 'tags#search'
  post '/tags/add', to: 'tags#add_tag_to_page'
  delete '/tags/remove', to: 'tags#remove_tag_from_page'
  get '/health', to: 'application#health_check'

  # Resource Versioning
  get '/versions/show/:model/:id', to: 'versions#show'

  resources :ak_logs

  resource  :action_kit, controller: 'action_kit' do
    member do
      post :check_slug
      post :create_petition_page
      get :check_petition_page_status
    end
  end

  # Standard resources
  resources :campaigns
  resources :donation_bands, except: [:show, :destroy]

  resources :pages do
    namespace :share do
      resources :facebooks
      resources :twitters
      resources :emails
    end

    get 'analytics', on: :member

    get 'follow-up', on: :member, action: 'follow_up'
    resources :images
    get 'plugins', to: 'plugins#index'
    get 'plugins/:type/:id', to: 'plugins#show', as: 'plugin'
  end

  resources :forms do
    resources :form_elements do
      post :sort, on: :collection
    end
  end

  namespace :plugins do
    resources :petitions
    resources :thermometers, only: :update
    resources :fundraisers, only: :update
    get 'forms/:plugin_type/:plugin_id/', to: 'forms#show', as: 'form_preview'
    post 'forms/:plugin_type/:plugin_id/', to: 'forms#create', as: 'form_create'
  end


  resources :liquid_partials, except: [:show]
  resources :liquid_layouts, except: [:show]
  resources :links, only: [:create, :destroy]

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

  namespace :api do
    namespace :braintree do
      get 'token'
      post 'pages/:page_id/transaction',  action: 'transaction', as: 'transaction'
      post 'braintree/webhook', action: 'webhook'
    end

    resources :pages do
      resource  :analytics
      resources :actions do
        post 'validate', on: :collection, action: 'validate'
      end
      get 'share-rows', on: :member, action: 'share_rows'
    end
  end
  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)
end
