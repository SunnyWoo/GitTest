namespace :neweb do
  post :writeoff
end

namespace :neweb_mpp do
  post :writeoff
  get :writeoff
end

namespace :pingpp do
  post :callback
end

namespace :sf_express do
  post :route
end

resources :delivered_mails, only: [:create]
resources :bounced_mails, only: [:create]
resources :dropped_mails, only: [:create]
resources :dropped_mails, only: [:create]
