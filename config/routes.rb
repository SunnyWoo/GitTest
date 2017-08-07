require 'api_constraints'
require 'constraints/email_sign_in_constraints'

CommandP::Application.routes.draw do
  # WARN: 使用此方法可能會造成 route 沒辦法正常 reload, 如果有這個問題請重開你的 server.
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end

  use_doorkeeper do
    skip_controllers :applications
    controllers tokens: :tokens
  end
  mount RailsEmailPreview::Engine, at: 'emails'
  devise_for :factory_members, path: :print, controllers: { sessions: 'print/sessions' }
  devise_for :admins, path: :admin
  devise_for :users, path: :account,
                     controllers: {
                       omniauth_callbacks: 'users/omniauth_callbacks',
                       registrations: 'users/registrations',
                       confirmations: 'users/confirmations',
                       sessions: 'users/sessions',
                       passwords: 'users/passwords'
                     }

  get '/who', to: 'api#who'
  get '/api/rn_version', to: 'api#rn_version'
  get '/api/rn_ios_version', to: 'api#rn_ios_version'
  get '/api/rn_android_version', to: 'api#rn_android_version'
  get '/version', to: 'application#version'
  get '/health-check', to: 'pages#health_check'

  namespace :api do
    scope module: :v1, constraints: ApiConstraints.new(version: 1) do
      draw :api_v1
    end

    scope module: :v2, constraints: ApiConstraints.new(version: 2) do
      draw :api_v2
    end

    scope module: :v3, constraints: ApiConstraints.new(version: 3) do
      draw :api_v3
    end
  end

  match '/pay_result' => 'pay_results#show', via: %w(get post)

  scope '(:locale)', locale: /..(-..)?/ do
    constraints subdomain: /store(?:-(pr|stg))?/ do
      devise_for :stores, path: 'backend'
      get :support, to: 'store/stores#support', as: 'store_support'
      get '/health-check', to: 'pages#health_check'
      get '/version', to: 'application#version'
      resources :stores, only: %w(index show), path: '/', module: 'store' do
        resources :products, only: %w(show)
        resources :works, only: %w(edit create) do
          patch :update, on: :member
          get :preview
          get :share, on: :member
          get :download, on: :member
        end

        resource :cart, only: %w(show) do
          post :add, on: :member
        end
      end

      namespace :store, path: '/' do
        draw :store
      end

      get '*', to: 'store/pages#not_found'
    end

    draw :frontend

    namespace :my do
      draw :my
    end

    namespace :admin do
      draw :admin
    end

    namespace :print do
      draw :print
    end

    namespace :mobile do
      draw :mobile
    end
  end

  namespace :webhook do
    draw :webhook
  end

  get '', to: redirect("/#{I18n.locale}")
  post '', to: redirect("/#{I18n.locale}")

  match '(:locale)/*path', via: :all, to: 'pages#not_found'
end
