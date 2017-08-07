class Store::BackendController < ApplicationController
  before_action :authenticate_store!
  layout 'store'

  helper_method :current_store

  def store_permitted_params
    @permitted_params ||= StorePermittedParams.new(params)
  end
end
