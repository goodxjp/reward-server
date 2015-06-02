# -*- coding: utf-8 -*-
Rails.application.routes.draw do
  resources :offers

  resources :media

  resources :networks

  devise_for :admin_users
  get 'welcome/index'
  get 'welcome/admin'

  resources :advertisements

  resources :campaigns do
    member do
      get 'execute'
    end
  end

  resources :media_users do
    member do
      get 'add_point_by_offer'
      get 'add_point_by_campaign'
    end
  end
  post 'media_users/:id/notify' => 'media_users#notify'

  # 商品
  resources :items do
    resources :gifts, :only => [ 'create' ]
    member do
      post 'register_codes'
    end
  end

  #
  # API
  # - http://ruby-rails.hatenadiary.com/entry/20150108/1420675366
  #
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :offers, :only => [ 'index' ] do
        member do
          get 'execute', format: 'html'  # 厳密にはブラウザから呼ばれるので API ではない
        end
      end
      resources :media_users, :only => [ 'show', 'create' ] do
        resources :point_histories, :only => [ 'index' ]
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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
