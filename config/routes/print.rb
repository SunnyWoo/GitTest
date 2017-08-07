get '/print', to: 'dashboard#index'
get '/sublimate', to: 'dashboard#sublimate'
get '/temp_shelves', to: 'dashboard#temp_shelf'
get '/package', to: 'dashboard#package'
get '/ship', to: 'dashboard#ship'
get '/search', to: 'dashboard#search'
get '/log', to: 'dashboard#log'
resources :order_items, only: [:index, :show] do
  patch '/sublimate', to: 'order_items#sublimate'
  patch '/reprint', to: 'order_items#reprint'
  patch :print, on: :member
  patch :print_all, on: :collection
  get :stamp, on: :member
end
resources :orders, only: [:show] do
  resources :notes
  put '/package', to: 'orders#package'
  get :package_parting
  get :splice_order
  put :update_invoice

  get :history, on: :collection
  get :deliver_orders, on: :collection
  get :schedule, on: :collection

  get :barcode, on: :member
  patch :disable_schedule, on: :member
end
get '/dropbox/authorize' => 'dropboxs#authorize', as: :dropbox_auth
get '/dropbox/callback' => 'dropboxs#callback', as: :dropbox_callback
get '/dropbox/' => 'dropboxs#index', as: :dropbox
resources :product_models, only: %w() do
  resource :imposition
  resources :demo_impositions, only: %w(create)
end
resources :impositions, only: 'index' do
  post :upload, on: :collection
end
# resources :factories, only: [:index, :update]
resources :print_items do
  patch '/reprint', action: :reprint

  patch :disable_schedule, on: :member
  collection do
    get :delayed
    get :delayed_history
    get :reprint_list
    get :reprint_history
    get :qualified_report
    get :schedule
  end
  get :delayed, on: :collection
  get :delayed_history, on: :collection

  resource :reception
end
resources :shelves do
  collection do
    get :stocking
    put :stock
    get :moving
    post :move
    get :seek
    get :changing
    put :change
    get :adjusting
    put :adjust
    get :restoring
    put :restore
    get :start_adjust
    get :finish_adjust
    get :activities
  end
end
resources :shelf_materials do
  member do
    get :adjusting
    put :adjust
  end

  collection do
    get :stocking
    put :stock
    get :seek
    get :activities
  end
end
resources :shelf_categories, only: [:new, :create]

resources :pickings, param: :model_id, only: [:index, :update]
resources :temp_shelves, only: [:new, :create, :edit, :update]
get '/pdf/product_ticker', to: 'pdf#product_ticker'
get '/pdf/b2b_sticker', to: 'pdf#b2b_sticker'
get '/pdf/delivery_note', to: 'pdf#delivery_note'
get '/pdf/delivery_note_back', to: 'pdf#delivery_note_back'
get '/pdf/sf_express_waybill', to: 'pdf#sf_express_waybill'
get '/pdf/yto_express_waybill', to: 'pdf#yto_express_waybill'
get '/pdf/package_delivery_note', to: 'pdf#package_delivery_note'

resources :role_groups
resources :user_roles
resources :roles, only: [:edit, :update]
resources :factory_members, only: [:edit, :update]
resources :batch_flows do
  post :start, on: :member
  get :history, on: :member
end
resources :packages, only: [:create, :index] do
  post :ship
  post :sf_express
  post :yto_express
end
resources :export_orders, only: [:index]
