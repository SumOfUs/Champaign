Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Custom paths
  post '/campaign_pages/new', to: 'campaign_pages#new'
  post '/campaign_pages/sign', to: 'campaign_pages#sign'

  # Specifies routing to templates controller for when a new template layout is requested by 
  # a user toggling different templates when creating a campaign page
  get '/templates/show_form/:id', to: 'templates#show_form'

  # Tagging pages
  get '/tags/search/:search', to: 'tags#search'
  post '/tags/add', to: 'tags#add_tag_to_campaign_page'
  delete '/tags/remove', to: 'tags#remove_tag_from_campaign_page'

  # Standard resources
  resources :campaigns

  resources :campaign_pages do
    namespace :widgets do
      resources :html, only: [:create]
    end
    resources :widgets, only: [:index, :destroy]
  end

  #/campaign_pages/1/widgets/html

  resources :templates


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
