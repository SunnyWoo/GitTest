class Admin::AvailableLocalesController < AdminController
  def index
    render json: I18n.available_locales
  end
end
