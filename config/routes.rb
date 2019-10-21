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

  get 'eoy_donations/:member_id/opt_out', to: 'eoy_donations#opt_out'
  get 'eoy_donations/:member_id/opt_in', to: 'eoy_donations#opt_in'

  resources :ak_logs

  resource  :action_kit, controller: 'action_kit' do
    member do
      post :check_slug
    end
    post :create_resources
  end

  # Standard resources
  resources :uris, except: %i[new edit]
  resources :campaigns
  resources :donation_bands, except: %i[show destroy]

  resources :pension_funds, except: %i[show destroy] do
    collection do
      get :export
      get :upload
      post :upload
    end
  end

  resources :clone_pages

  resources :featured_pages, except: %i[show new edit]

  resources :pages do
    namespace :share do
      put 'endpoint', to: 'shares#update_url', as: 'endpoint'
      resources :facebooks
      resources :twitters
      resources :emails
      resources :whatsapps
    end

    get 'analytics', on: :member
    get 'actions',   on: :member
    get 'preview',   on: :member
    get 'emails',    on: :member
    get 'feeds',     on: :collection, defaults: { format: 'xss' }

    get 'follow-up', on: :member, action: 'follow_up'
    get 'confirmation', on: :member, action: 'double_opt_in_notice'

    resources :images
    get 'plugins', to: 'plugins#index'
    get 'plugins/:type/:id', to: 'plugins#show', as: 'plugin'

    resource :archive, only: %i[create destroy], controller: 'page_archives'
  end

  resources :pages, path: 'a', as: 'member_facing_page', only: %i[edit show] do
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
    resources :call_tools, only: :update do
      delete :sound_clip, on: :member, action: :delete_sound_clip
      post :sound_clip, on: :member, action: :update_sound_clip
      post :targets, on: :member, action: :update_targets
      get :export_targets, on: :member
    end
    resources :email_tools do
      post :targets, on: :member, action: :update_targets
    end

    post 'surveys/:plugin_id/form', to: 'surveys#add_form', as: 'add_survey_form'
    put 'surveys/:plugin_id/sort', to: 'surveys#sort_forms', as: 'sort_survey_forms'
    get 'forms/:plugin_type/:plugin_id/', to: 'forms#show', as: 'form_preview'
    post 'forms/:plugin_type/:plugin_id/', to: 'forms#create', as: 'form_create'
  end

  resources :liquid_partials, except: [:show]
  resources :liquid_layouts, except: [:show]
  resources :links, only: %i[create destroy]

  # legacy route
  get '/api/braintree/token', to: 'api/payment/braintree#token'

  resource :member_authentication, only: %i[new create]
  resource :reset_password

  namespace :api do
    scope :shares do
      post 'track', to: '/share/shares#track'
    end

    get 'donations/total'

    resources :email_target_emails, only: [:index] do
      collection do
        post 'download'
      end
    end

    resources :pending_action_notifications, only: [] do
      member do
        put 'delivered'
        put 'opened'
        put 'bounced'
        put 'complaint'
        put 'clicked'
      end
    end

    resource :action_confirmations, only: [] do
      member do
        get 'confirm'
        post 'resend_confirmations'
      end
    end

    resources :pension_funds, only: [:index] do
      collection do
        post 'suggest_fund'
      end
    end

    namespace :payment do
      namespace :braintree, defaults: { format: 'json' } do
        get 'token'
        get 'refund'
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
      get 'actions', on: :member, action: 'actions'
      get 'featured', on: :collection
      get 'similar'
      get 'total_donations'

      resource :analytics, only: [:show] do
        get 'call_tool', on: :member
      end

      resources :actions, only: %i[create update] do
        post 'validate', on: :collection, action: 'validate'
      end
      resources :survey_responses, only: [:create]
      resource :call, only: [:create]
      post 'emails', to: 'emails#create'
      post 'action_emails', to: 'emails#create_unsafe'
      post 'pension_emails', to: 'emails#create_pension_email'
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

      resources :members do
        resource :consent, only: [:create]
      end

      delete '/api/consent', to: 'api/stateless/consents#destroy'

      resource :consent, only: %i[create destroy]

      namespace :auth do
        post :password
        post :facebook
        get :test_authentication
      end

      get :location, to: 'location#index'
    end

    resources :members

    post 'members/forget', to: 'members#forget'

    # Respond to CORS Preflight requests (OPTIONS) with a
    # 204 No Content
    match '*path', via: :options, to: lambda { |_|
      [204, { 'Content-Type' => 'text/plain' }, []]
    }

    namespace :member_services do
      get '/gocardless/customers', action: :gocardless_customers
      get '/subject_access_request/', action: :subject_access_request
      put '/members/', action: :update_member
      post '/members/forget', action: :forget_member
      delete '/recurring_donations/:provider/:id', action: :cancel_recurring_donation
    end
  end

  post '/twilio/calls/:id/start',              to: 'twilio/calls#start', as: :call_start
  post '/twilio/calls/:id/menu',               to: 'twilio/calls#menu', as: :call_menu
  post '/twilio/calls/:id/connect',            to: 'twilio/calls#connect', as: :call_connect
  post '/twilio/calls/:id/target_call_status', to: 'twilio/calls#create_target_call_status', as: :target_call_status
  post '/twilio/calls/:id/member_call_event',  to: 'twilio/calls#create_member_call_event', as: :member_call_event
  get 'generate_cookie', to: 'payment#generate_cookie'

  root to: 'uris#show'
  mount MagicLamp::Genie, at: '/magic_lamp' if defined?(MagicLamp) && ENV['JS_TEST']
  get '*path' => 'uris#show' unless defined?(MagicLamp) && ENV['JS_TEST']
end
