class Store::Backend::DemosController < Store::BackendController
  layout 'store_backend/application'
  before_action :verify_accessibility

  def elements
  end

  private

  def verify_accessibility
    raise ActiveRecord::RecordNotFound unless Rails.env.development?
  end
end
