post 'campaigns/waterpackage', to: 'campaigns#waterpackage'

get '/info' => 'info#show', as: :info
get '/me' => 'profiles#show', as: :profile
patch '/me/touch' => 'profiles#touch', as: :touch_profile
patch 'me' => 'profiles#update', as: :update_profile
patch 'me/upload_avatar' => 'profiles#upload_avatar', as: :upload_avatar
post '/sign_up', to: 'registrations#create'
get 'validate' => 'coupons#validate'
delete '/sign_out', to: 'sessions#destroy'
get 'app_version' => 'site_settings#app_version'

resource :country_code, only: 'show'
resource :currency_code, only: 'show'
resources :banners, only: 'index'
resources :confirmations, param: :confirmation_token, only: [:create, :show]
resources :announcements, only: 'index'
resources :home_blocks, only: 'index'
resources :home_slides, only: 'index'
resources :home_links, only: 'index'
resources :header_links, only: :index
resources :campaigns, only: %w(index show)
resources :attachments, only: %w(create show)
resources :newsletter_subscriptions, only: 'create'
resources :users, only: [:show] do
  post :bind_mobile, on: :collection
end
resources :supports, only: %w(index create)
resources :questions, only: 'index'
resources :innate_materials, only: 'index'
resources :fonts, only: 'index'
resource :header_button
resources :products, only: %w(index)
resources :product_models, only: %w(show index) do
  get :des_images, on: :member
  resources :templates, only: :index
end
resource :mobile, controller: :mobile, only: [] do
  get :code
  post :verify
  post :forget_password
  post :reset_password
end

resource :cart do
  resources :items, only: [:create], controller: :cart_items do
    delete :destroy, on: :collection
    put :update, on: :collection
  end
  post :check_out
end
resources :mobile_uis, only: [] do
  get :template, on: :collection
end

namespace :my do
  resources :wishlists, only: %w(destroy) do
    get :show, on: :collection
    post :create, on: :member
  end
  resources :orders, param: :uuid, only: %w(index show update) do
    resources :items
    patch '/pay', to: 'orders#pay'
    post '/price', to: 'orders#price', on: :collection
    patch 'judge_for_repay', to: 'orders#judge_for_repay'
    patch 'postpone_payment', to: 'orders#postpone_payment'
    patch :destroy, on: :member
    put :cancel, on: :member
  end
  resources :address_infos, except: %w(new edit)
  resources :works, param: :uuid, only: %w(index show update destroy) do
    resources :layers, param: :uuid, only: %w(update destroy)
    post :finish, on: :member
  end

  namespace :works do
    resources :batches, param: :uuid, only: %w(update)
  end
  resources :work_specs, only: [] do
    resources :templates, only: :index
  end
  resources :asset_packages, only: %w(index destroy) do
    post :create, on: :member
  end
end
resources :devices, param: :token, only: [:index, :update]

concern :paymentable do
  get :begin
  post :verify
  get :retrieve
end

namespace :payment do
  resource :pingpp, controller: :pingpp, only: [], concerns: :paymentable

  resource :pingpp_wap, only: [] do
    post :begin
  end

  resource :paypal, controller: :paypal, only: [], concerns: :paymentable
  resource :stripe, controller: :stripe, only: [], concerns: :paymentable
  resource :neweb_mpp, controller: :neweb_mpp, only: [], concerns: :paymentable
  resource :neweb_atm, controller: :neweb_atm, only: [] do
    get :begin
  end

  resource :neweb_mmk, controller: :neweb_mmk, only: [] do
    get :begin
  end
  resource :redeem, controller: :redeem, only: [] do
    get :begin
  end
end

# put '/works/:uuid' => 'works#update', as: :create_work
resources :works, shallow: true, param: :id, only: %w(show index) do
  get :related, on: :member
  resources :reviews, only: %w(index create)
  resources :layers, param: :uuid, only: %w(index)
  resources :previews, only: %w(index)
end

resources :standardized_works, shallow: true, only: %w(index show) do
  resources :reviews, only: %w(index create)
  get :related, on: :member
  patch :touch, on: :member
  resources :previews, only: %w(index)
end
resource :reset_password_token, only: %w(create update)
resources :password do
  put :update, on: :collection
end

resources :asset_package_categories, only: :show
resources :asset_packages, only: :show
resources :mobile_pages, param: :key, only: %w(index show) do
  get :preview, on: :member
end

namespace :deliver_order do
  resources :remote_infos, param: :remote_id, only: [:index, :show, :update]
  resources :orders, only: :create do
    put :cancel
    get :single_item_infos, on: :collection
  end
  resources :order_items, only: :show
end
resources :contacts, only: %w(create)
resources :provinces, only: %w(index)

resources :stores, only: %w(show)
