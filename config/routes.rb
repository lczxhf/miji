Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
   require 'sidekiq/web'
      require 'sidetiq/web'
         mount Sidekiq::Web => '/sidekiq'
  # See how all your routes lay out with "rake routes".
	mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # You can have the root of your site routed with "root"
  # root 'welcome#index'
namespace :api do
  get "third_party/home" => "third_party#home"
  post "third_party/receive" => "third_party#receive"
  get "third_party/auth_code" => "third_party#auth_code"
  get "third_party/oauth2" => "third_party#oauth2"
  get "third_party/authorize" => "third_party#authorize"
  post 'message/:appid' => "message#receive"

  post 'backrequire/get_user_info' => 'backrequire#get_user_info'

  post 'backrequire/get_access_token' => "backrequire#get_access_token"

  post "wechat/upload_new_media" => "wechat#upload_new_media"
  post "wechat/upload_image_media" => "wechat#upload_image_media"
    post "wechat/upload_news_img" => "wechat#upload_news_img"
end

namespace :page do
  resources :new_media do
	post :sync, on: :collection
  end
  resources :content_media
  resources :media
  resources :setting_news
  resources :normal_news
  #post "new_media/change_normal_new" => "new_media#change_normal_new"
end
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
