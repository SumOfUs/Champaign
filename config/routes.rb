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

  # Express donations email confirmation path
  get '/email_confirmation/', to: 'email_confirmation#verify'

  resources :ak_logs

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
    resources :surveys, only: :update
    resources :texts, only: :update
    post 'surveys/:plugin_id/form', to: 'surveys#add_form', as: 'add_survey_form'
    put 'surveys/:plugin_id/sort', to: 'surveys#sort_forms', as: 'sort_survey_forms'
    get 'forms/:plugin_type/:plugin_id/', to: 'forms#show', as: 'form_preview'
    post 'forms/:plugin_type/:plugin_id/', to: 'forms#create', as: 'form_create'
  end

  resources :liquid_partials, except: [:show]
  resources :liquid_layouts, except: [:show]
  resources :links, only: [:create, :destroy]

  # legacy route
  get '/api/braintree/token', to: 'api/payment/braintree#token'

  resource :member_authentication
  resource :reset_password

  namespace :api do
    namespace :payment do
      namespace :braintree, defaults: { format: 'json' } do
        get 'token'
        post 'pages/:page_id/transaction',  action: 'transaction',  as: 'transaction'
        post 'pages/:page_id/one_click',    action: 'one_click',    as: 'one_click'
        get  'pages/:page_id/link_payment', action: 'link_payment', as: 'link_payment'
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
      resources :survey_responses, only: [:create]
    end

    namespace :stateless, defaults: { format: 'json' } do
      namespace :braintree do
        resources :payment_methods
        resources :subscriptions
        resources :transactions
      end

      namespace :go_cardless do
        resources :payment_methods
        resources :subscriptions
        resources :transactions
      end

      resources :members

      namespace :auth do
        post :password
        post :facebook
        get :test_authentication
      end
    end


    post '/twilio', to: 'twilio#index'

    resources :members

    # Respond to CORS Preflight requests (OPTIONS) with a
    # 204 No Content
    match '*path', via: :options, to: lambda { |_|
      [204, { 'Content-Type' => 'text/plain' }, []]
    }
  end

  root to: 'uris#show'
  mount MagicLamp::Genie, at: '/magic_lamp' if defined?(MagicLamp) && ENV['JS_TEST']
  get '*path' => 'uris#show' unless defined?(MagicLamp) && ENV['JS_TEST']
end
