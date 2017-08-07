namespace :my do
  resources :devices, only: [:create, :update, :index, :destroy]
  resources :works, param: :uuid do
    resources :layers, param: :uuid
    patch '/finish', to: 'works#finish', on: :member
  end
  resources :orders, param: :uuid do
    resources :items
    patch '/pay', to: 'orders#pay'
  end
end

resources :users, only: [:create]
resources :product_models, only: [:index]
resources :works, param: :uuid do
  resources :layers, param: :uuid
end

get '/validate', to: 'coupons#validate'
post '/sign_in', to: 'auth#create'
delete '/sign_out', to: 'auth#destroy'
get '/shipping_fee', to: 'fees#shipping_fee'
get '/fees', to: 'fees#index'
get '/app_version', to: 'site_settings#app_version'
get '/country_code', to: 'search#country_code'
post '/test/upload', to: 'test#upload'
get '/test/fb_test_user', to: 'test#fb_test_user'
delete '/test/delete_fb_test_user', to: 'test#delete_fb_test_user'
