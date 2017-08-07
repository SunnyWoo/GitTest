namespace :backend do
  root 'stores#show'

  resources :demos, only: %w(elements) do
    get :elements, on: :collection
  end

  resources :product_templates, except: %w(destroy) do
    resource :design, only: %w(edit update)
    resource :preview, only: %w(show)
    resource :status, only: %w(edit update)
    resources :preview_composers, only: [] do
      patch :update, on: :collection
      get :edit, on: :collection
    end
  end

  resource :store, only: %w(edit update show)
  resource :layout, only: %w(edit update)
  resources :standardized_works, except: %w(show destroy create) do
    post :work_set, on: :collection
    patch :publish, :pull, on: :member
  end
end

get 'orders/search', to: 'orders#search'
match 'orders/search_result', to: 'orders#search_result', via: %w(get post)
