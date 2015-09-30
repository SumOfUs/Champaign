Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # We remove the sign_up path name so as not to allow users to sign in with username and password.
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }, path_names: { sign_up: ''}

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Specifies routing to templates controller for when a new template layout is requested by 
  # a user toggling different templates when creating a campaign page

  # Tagging pages
  get '/tags/search/:search', to: 'tags#search'
  post '/tags/add', to: 'tags#add_tag_to_page'
  delete '/tags/remove', to: 'tags#remove_tag_from_page'

  resources :ak_logs

  # Standard resources
  resources :campaigns

  resources :pages do
    namespace :share do
      resources :facebooks
      resources :twitters
      resources :emails
    end

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
    resources :actions do
      resources :forms, module: :actions
      resource :preview, module: :actions
    end
    resources :thermometers
  end


  resources :liquid_partials
  resources :liquid_layouts
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
    resources :pages do
      resources :actions
    end
  end
  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
