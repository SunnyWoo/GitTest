resources :redeems do
  collection do
    get :work
    get :check_out
    get :success
    post :mobile_web_check_out
  end
end

resources :redeem_works, only: [:create, :edit] do
  member do
    get :preview
  end
end
