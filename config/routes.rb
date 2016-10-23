Rails.application.routes.draw do

  devise_for :members, controllers: { registrations: "registrations" }
  devise_scope :member do
    get "/admin" => "devise/sessions#new"
  end

  root to: 'admin/welcomes#index'

  mount API => '/'
  get 'admin'=>'devise/sessions#new'

  resources :service_agreement, only: :index do
    collection do
      get :app_download
    end
  end

  namespace :admin do
    resources :categories do
      member do
        post :stick_top
        get :export_product
      end
    end
    resources :sub_categories do
      member do
        post :stick_top
      end
    end
    resources :detail_categories do
      collection do
        get :select_category
      end
      member do
        post :stick_top
      end
    end
    resources :hot_categories
    resources :users do
      member do
        get :user_statistics
      end
    end
    resources :products do
      collection do
        get :select_category
        post :upload_csv
      end
      member do
        get :delete_image, :image, :statistics, :new_stock
        post :stick_top, :create_stock
      end
    end
    resources :product_admins do
      collection do
        get :select_category, :statistics
      end
    end
    resources :addresses
    resources :orders do
      delete :delete_order_product, on: :member
      collection do
        post :add_order_product
        get :select_product
        get :search_product
      end
      member do
        get :export_order
      end
    end
    resources :promoters do
      member do
        get :statistics
      end
    end
    resources :members do
      member do
        get :system_setting
        post :update_system_setting
      end
    end
    resources :units
    resources :adverts
    resources :cars
    resources :deliverymen
    resources :storehouses
    resources :product_stat
    resources :order_stat, only: :index
    resources :export_to_erps, only: :index
  end

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
