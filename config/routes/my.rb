resources :works, only: %w(edit) do
  get 'preview'
  get 'share'
end
