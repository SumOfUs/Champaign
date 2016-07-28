# frozen_string_literal: true
Rails.application.routes.draw do
  if Settings.google_verification
    match "/#{Settings.google_verification}.html", to: proc { |_env| [200, {}, ["google-site-verification: #{Settings.google_verification}.html"]] }, via: :get
  end

  ActiveAdmin.routes(self)

  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }

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

  resource  :action_kit, controller: 'action_kit' do
    member do
      post :check_slug
    end
  end

  # Standard resources
  resources :uris, except: [:new, :edit]
  resources :campaigns
  resources :donation_bands, except: [:show, :destroy]

  resources :clone_pages

  resources :featured_pages, except: [:show, :new, :edit]

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

    resource :archive, only: [:create, :destroy], controller: 'page_archives'
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
      namespace :braintree, defaults: { format: 'json' } do
        get 'token'
        post 'pages/:page_id/transaction', action: 'transaction', as: 'transaction'
        post 'webhook', action: 'webhook'
      end
    end

    namespace :go_cardless do
      get 'pages/:page_id/start_flow', action: 'start_flow'
      get 'pages/:page_id/transaction', action: 'transaction', as: 'transaction'
      post 'webhook'
    end

    resources :pages do
      get 'share-rows', on: :member, action: 'share_rows'
      get 'featured', on: :collection

      resource  :analytics
      resources :actions do
        post 'validate', on: :collection, action: 'validate'
      end
    end

    namespace :stateless, defaults: { format: 'json' } do
      namespace :auth do
        post :password
        post :facebook
        get :test_authentication
      end
    end

    resources :members

    # Respond to CORS Preflight requests (OPTIONS) with a
    # 204 No Content
    match '*path', via: :options, to: lambda { |_|
      [204, { 'Content-Type' => 'text/plain' }, []]
    }
  end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root to: 'uris#show'
  mount MagicLamp::Genie, at: '/magic_lamp' if defined?(MagicLamp) && ENV['JS_TEST']
  get '*path' => 'uris#show' unless defined?(MagicLamp) && ENV['JS_TEST']
end
