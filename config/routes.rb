Rails.application.routes.draw do

  root 'public#index'
  #TODO why cant I use dashses instead of underscores in route names?
  get 'privacy_policy' => 'public#privacy_policy'
  get 'terms_of_service' => 'public#terms_of_service'
  get 'contact' => 'public#contact'
  get 'public/upload_notice' => 'public#upload_notice'

  get 'books/recent(/page/:page)' => 'books#recent', as: 'recent_books'
  get 'books/popular(/page/:page)' => 'books#popular', as: 'popular_books'
  get 'books/:author/:title/read(/:page)' => 'books#read', as: 'read_book'
  get 'books/:id/read(/:page)' => 'books#read_id', as: 'read_id_book'
  
  #TODO - remove this route and ensure home page is pagable
  #get 'public/index'

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
