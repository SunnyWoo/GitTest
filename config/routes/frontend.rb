require 'sidekiq/web'
mount Judge::Engine => '/judge'

get '/about', to: 'pages#about'
get '/terms', to: 'pages#terms'
get '/terms_of_service', to: 'pages#terms_of_service'
get '/privacy', to: 'pages#privacy'
get '/support', to: 'pages#support'
post '/upload', to: 'editor#no_op'
get '/career', to: 'pages#career'
get '/careers', to: 'pages#careers'
post '/receive_support', to: 'pages#receive_support'
get '/search', to: 'search#index'
get '/robots.txt', to: 'pages#robots'
# get '/shop', to: 'shops#index'
# get '/shop/:product_model_id/:work_id', to: 'works#show', as: :shop_work

get '/mobile/faq', to: 'mobile_view#faq'
get '/mobile/code', to: 'mobile_view#code'
get '/captcha/verify', to: 'captcha#verify'

resources :shop, only: %w(index show), controller: 'shops' do
  get ':id', to: 'works#show', as: :work
end

resources :comments, only: [:create]
resources :questions, only: [:index]
resources :orders, except: %w(show) do
  get '/order_status', to: 'orders#order_status', on: :collection
  get '/check_order_status', to: 'orders#check_order_status', on: :collection
end

resources :rewards, only: [] do
  post :show, on: :member
  get :download
  patch :validate, on: :collection
end

get 'rewards/:id', to: 'rewards#share', as: :reward_share


resources :order_results, only: %w(show)
resources :users do
  collection do
    post '/upload_avatar', to: 'users#upload_avatar'
    get '/profile', to: 'users#profile'
    get '/address', to: 'users#address'
    get '/order_history', to: 'users#order_history'
    get '/order/:order_no', to: 'users#order', as: :order
    get '/works', to: 'users#works'
  end
end

post '/user_backgrounds/update', to: 'user_backgrounds#update'
resources :cart do
  put 'add', to: 'cart#add', on: :member
  collection do
    resource :coupon, controller: :cart_coupons, only: %w(create destroy)
    get '/check_out', to: 'cart#check_out'
    patch '/check_out_update', to: 'cart#check_out_update'
    get '/summary', to: 'cart#summary'
    match '/payment/neweb_alipay', to: 'cart#neweb_alipay_callback', via: %w(get post)
  end
end
resources :works do
  get :preview
  patch :finish
  resources :layers
  resource :cover_image, only: 'update'
  resources :preview_images, only: 'show', controller: 'previews'
  resources :reviews, only: %w(index create)
  get :questionnaire, on: :collection
end
resources :archived_works, only: 'show'
resources :wishlists, only: [:index, :destroy] do
  get :add, on: :member
end

namespace :payment do
  resource :paypal, controller: 'paypal', only: [] do
    post :begin
    get :callback, :finish
  end

  resource :cash_on_delivery, controller: 'cash_on_delivery', only: [] do
    post :begin
    get :finish
  end

  resource :neweb_atm, controller: 'neweb_atm', only: [] do
    post :begin
    get :finish
  end

  resource :neweb_mmk, controller: 'neweb_mmk', only: [] do
    post :begin
    get :finish
  end

  resource :neweb_alipay, controller: 'neweb_alipay', only: [] do
    post :begin, :callback
    get :finish
  end

  resource :neweb_mpp, controller: 'neweb_mpp', only: [] do
    post :begin, :callback
    get :finish
  end

  resource :stripe, controller: 'stripe', only: [] do
    post :begin, :callback
    get :finish
  end

  resource :pingpp_alipay_qr, controller: 'pingpp_alipay_qr', only: [] do
    post :begin
    get :pay_result
  end
end

get 'account/sign_in', to: 'users/sessions#new', as: :new_account_sign_in
post 'account/sign_in', to: 'users/sessions#create', constraints: ::Constraints::EmailSignInConstraints.new(way: 'normal')
delete 'account/sign_out', to: 'users/sessions#destroy', constraints: ::Constraints::EmailSignInConstraints.new(way: 'normal')

resources :address_infos
resources :newsletter_subscriptions, only: %w(create)
root to: 'pages#home', defaults: { format: :html }

namespace :webapi, defaults: { format: :json } do
  get 'search/works', to: 'search#works'
end

get '/proxy' => 'pages#proxy'

get 'campaign/2016lucky', to: redirect('campaign/lucky2016')
get 'campaign/:id', to: 'campaign#show', as: :campaign

get 'product/info', to: 'product#info'

resources :media, id: /[a-zA-Z0-9+\/%=]+--[a-f0-9]{40}/, only: 'show' do
  get :recreate_versions, on: :member
end
resources :bdevents, only: %w(index)
resources :redeems, only: [:new, :create, :verify] do
  post :verify, to: 'redeems#verify', on: :collection
end

resource :instagram, only: %w(show)
