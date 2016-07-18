Rails.application.routes.draw do

  if Settings.google_verification
    match "/#{Settings.google_verification}.html", to: proc { |env| [200, {}, ["google-site-verification: #{Settings.google_verification}.html"]] }, via: :get
  end

  ActiveAdmin.routes(self)

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  root to: 'home#index'

  # Tagging pages
  get '/tags/search/:search', to: 'tags#search'
  post '/tags/add', to: 'tags#add_tag_to_page'
  delete '/tags/remove', to: 'tags#remove_tag_from_page'

  # Custom health check route
  get '/health', to: 'home#health_check'

  # For crawlers
  get '/robots.:format' => 'home#robots'

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

  resources :clone_pages

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

  resources :pages, path: 'a', as: 'member_facing_page', only: [:edit, :show] do
    get 'follow-up', on: :member, action: 'follow_up'
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

  # legacy route
  get '/api/braintree/token', to: 'api/payment/braintree#token'

  namespace :api do
    namespace :payment do
      namespace :braintree, defaults: {format: 'json'} do
        get 'token'
        post 'pages/:page_id/transaction',  action: 'transaction', as: 'transaction'
        post 'webhook', action: 'webhook'
      end
    end

    namespace :go_cardless do
      get 'pages/:page_id/start_flow', action: 'start_flow'
      get 'pages/:page_id/transaction', action: 'transaction', as: 'transaction'
      post 'webhook'
    end

    namespace :pages do
      get 'featured/', action: 'show_featured'
    end

    resources :pages do
      resource  :analytics
      resources :actions do
        post 'validate', on: :collection, action: 'validate'
      end

      get 'share-rows', on: :member, action: 'share_rows'
    end

    resources :members 
  end
  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)
end
