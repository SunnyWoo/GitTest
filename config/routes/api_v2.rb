resources :products, only: %w(index)
resources :banners, only: %w(index)
post '/sign_up', to: 'registrations#create', constraints: ::Constraints::EmailSignInConstraints.new(way: 'normal')
post '/sign_in', to: 'sessions#create', constraints: ::Constraints::EmailSignInConstraints.new(way: 'normal')
delete '/sign_out', to: 'sessions#destroy'
post '/sign_in', to: 'auths#create', constraints: ::Constraints::OauthConstraints.new(way: 'oauth')

resources :confirmations, param: :confirmation_token, only: [:create, :show]
resource :mobile, controller: :mobile, only: [] do
  get :code
  post :verify
  get :forget_password
  post :reset_password
end

namespace :my do
  resources :works, param: :uuid, only: %w(show update) do
    post :finish, on: :member
    resources :layers, param: :uuid, only: %w(update destroy)
  end
  resources :orders, param: :uuid, only: %w(index show update price) do
    resources :items
    patch '/pay', to: 'orders#pay'
    post '/price', to: 'orders#price', on: :collection
  end
  resources :devices, param: :token, only: [:index, :update]
  resources :notification_trackings, only: %w(create)
end
resources :standardized_works, only: :index
resources :product_models, only: [] do
  resources :templates, only: :index
end
namespace :payment do
  resource :pingpp, controller: :pingpp, only: [] do
    get :begin
    get :verify
  end
end
get '/me', to: 'users#show'
post '/merge_user', to: 'users#merge'
post '/bind_mobile', to: 'users#bind_mobile'
get '/validate', to: 'coupons#validate'

shallow do
  namespace :my do
    resources :asset_packages, only: %w(index) do
      member do
        post :create
        delete :destroy
      end
    end
  end
  resources :asset_packages, only: %w(index) do
    resources :assets, only: %w(index)
  end
end
resources :devices, param: :token, only: [:update]
resources :mobile_uis, only: [] do
  get :template, on: :collection
end
resources :notification_trackings, only: %w(create)
resources :password do
  put :update, on: :collection
end
resource :reset_password_token, only: %w(create update)
resources :bdevents, only: %w(index)

unless Rails.env.production?
  namespace :admin do
    resources :users
    resources :omniauths, only: [:show, :destroy]
  end
end
