authenticate :admin do
  mount Sidekiq::Web => '/sidekiq'
end
root 'users#index'

concern :versionable do
  resources :versions, only: :index
end

resources :activities, only: %w(index)
resources :admins do
  patch :unlock, on: :member
  get :log, on: :member
end
resources :site_settings, except: [:destroy]
resources :users do
  member do
    post :clear_mobile
    post :publish_notification
  end
end
resources :notifications do
  member do
    get :activities, to: 'notifications#activities'
    get :report, to: 'notifications#report'
  end
end

resource :sms_marketing, only: %i(show) do
  member do
    post :send_sms
    get :preview
  end
end

resources :announcements
resources :fees
resources :orders do
  collection do
    get :search, to: 'orders#search'
    get :unapproved, to: 'orders#unapproved'
    get :unapproved_counts, to: 'orders#unapproved_counts'
    get :approve_invoice, to: 'orders#approve_invoice'
    get :approve_invoice_activities, to: 'orders#approve_invoice_activities'
    put :batch_update, to: 'orders#batch_update'
    patch :invoice_upload, to: 'orders#invoice_upload'
    patch :invouce_check, to: 'orders#invouce_check'
    get :index_init, to: 'orders#index_init'
  end
  member do
    patch :unwatch
    patch :watch
    patch :invoice_required
    patch :cancel_invoice
  end
  patch '/update_remote_info', to: 'orders#update_remote_info'
  post :receipt, to: 'orders#send_receipt'
  patch '/refund', to: 'orders#refund'
  patch '/approve', to: 'orders#approve'
  get '/history', to: 'orders#history'
  get '/paypal_sale_id', to: 'orders#paypal_sale_id'
  get :edit_ship, to: 'orders#edit_ship'
  patch 'update_shipping_info', to: 'orders#update_shipping_info'
  patch :unlock
  resources :billing_infos, only: %w(edit update) do
    get :change_country_code, on: :member
  end
  resources :shipping_infos, only: %w(edit update) do
    get :change_country_code, on: :member
  end
  resources :notes
  resources :adjustments, only: %i(create)
end
resources :order_items do
  resources :notes
end
resources :products, only: %w(index)
resources :product_categories, only: %w(index new create show edit update) do
  put :update_position, on: :member
end
resources :product_models, concerns: :versionable do
  resources :work_templates
  resources :preview_composers do
    post :rebuild, on: :collection
  end
  put :update_position, on: :member
  get :sort, on: :collection
  get :export, on: :collection
  match :import, on: :collection, via: %w(get post)
  resources :variants
end
resources :preview_composers, only: [] do # TODO: shallow all routes
  resources :samples, only: %w(index), controller: 'preview_samples', shallow: true
end
resources :currency_types
resources :price_tiers, only: %w(index show) do
  put :update, on: :collection
end
resources :coupons do
  get :search, on: :collection
  get :code, on: :collection
  get :children, on: :member
  get :used_orders, on: :member
  get :available_coupons, on: :collection
end
resources :coupon_notices do
  get :preview, on: :collection
end
resources :works do
  resources :layers, shallow: true
  member do
    post :refresh
    post :restore
  end
  collection do
    get :search
  end
  get '/history', to: 'works#history'
  resource :print_image
  resource :order_image
  resource :ai, controller: 'ai'
  resources :notes
  resources :previews, shallow: true
end
resources :standardized_works do
  post :publish, :pull, on: :member
  get :search, on: :collection
  resources :archives, controller: :archived_standardized_works, only: 'create'
end
resources :archived_works do
  resources :archived_layers, shallow: true, concerns: :versionable
  resource :print_image
  resource :fixed_image
  resource :order_image
  resource :ai, controller: 'ai'
  post :recopy_layers, on: :member
end
resources :emails do
  collection { post :sending, to: 'emails#sending' }
end
mount PgHero::Engine, at: 'pghero'
resources :questions
resources :question_categories
resources :reports do
  patch :update_report, on: :collection
end
resources :designs do
  post :measure, on: :collection
  resource :work, controller: 'design_works'
end
resources :home_slides
resources :messages, only: %w(index show) do
  post :resend, on: :member
end
resources :features, only: %w(index) do
  patch :enable, on: :member
  patch :disable, on: :member
end

resources :home_products, only: %w(index) do
  put :update, on: :collection
  get :work_names, on: :collection
end

resources :banners
resources :designers
resources :work_sets
resources :work_set_befores, only: %w(create)
resources :translations
shallow do
  resources :asset_packages do
    put :update_position, on: :member
    resource :icon, controller: 'asset_package_icons', only: 'create'
    resources :assets
    get :edit_file, on: :collection
    put :update_file, on: :collection
  end
  resources :countries
end
resources :devices, only: %w(index) do
  get :count, on: :collection
end
resources :mobile_uis
resources :home_links do
  put :sort, on: :member
end
resources :header_links do
  put :update_position, on: :member
  get :rows, on: :member
  get :sort, on: :collection
end
resources :newsletter_subscriptions
resources :newsletters do
  patch :get_report, to: 'newsletters#get_report', on: :member
  patch :send_mail, to: 'newsletters#send_mail', on: :member
end
shallow do
  resources :home_blocks
  resources :home_block_items
  resources :home_block_item_translations, only: [] do
    patch :update_pic, on: :collection
  end
  resources :jobs
  resources :tags do
    member do
      get :works
      get :tagging_position
      put :tagging_position, to: 'tags#update_tagging_position'
      delete :tagging_position, to: 'tags#remove_tagging_position'
    end
    get :all_works, on: :collection
    put :work_tags, on: :collection
  end
  resources :available_locales
  resources :oauth_apps
end
post '/tinymce_assets' => 'tinymce_assets#create'
resources :auto_coupons, only: %w(index create)
resources :email_banners
resources :campaigns
resources :asset_package_categories, except: %w(destroy)
resources :bdevents do
  patch :update_flex, on: :collection
end
resources :masks, only: [:index, :new, :create, :destroy]

resources :imposition, only: [], concerns: :versionable
resources :mobile_campaigns do
  put :update_position, on: :member
end
resources :attachments, only: 'create'
resources :mobile_pages do
  get :search_campaign, on: :collection
  put :preview, on: :member
  get :preview_by_device, on: :member
  resources :mobile_components do
    put :update_position, on: :member
  end
end

get :examples
resources :collections do
  member do
    get :works
    get :tags
    post :add_tag
    delete :remove_tag
    get :work_position
    put :work_position, to: 'collections#update_work_position'
    delete :work_position, to: 'collections#remove_work_position'
  end
end

resources :product_codes, only: [:index, :create, :edit, :update] do
  collection do
    get :exporting
    post :export
  end
end
resources :channel_codes, only: [:index, :create, :edit, :update]
resources :factories, :factory_members
resources :deliver_orders, only: :index do
  collection do
    get :deliver_failed
    put :repair_images
  end
end
resources :recommend_sorts, only: [:index, :edit, :update]
resources :import_orders, only: [:index, :create] do
  post :retry
end
resources :promotions do
  resources :references, controller: 'promotion_references'
  member do
    get :works
    put :update_promotion_references
    put :submit
    put :manual
    post :apply
    delete :fallback
  end
end
resources :purchase_categories
resources :purchase_durations, only: :index

get 'dashboard/watching_order', to: 'dashboards#watching_order'
resources :change_price_events, only: %i(index new create) do
  collection do
    get :works
    get :target_list
  end
  member do
    put :rerun
    get :histories
  end
end

get '/b2b_orders/stickers', to: 'b2b_orders#stickers'
post '/b2b_orders/stickers', to: 'b2b_orders#create_stickers'
resources :stores

resource :daily_report, only: %w(show) do
  get :order_sticker
end
resources :option_types
resources :rewards, except: %w(show destroy)
resources :cp_resources
