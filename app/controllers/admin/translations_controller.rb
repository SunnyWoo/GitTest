class Admin::TranslationsController < AdminController
  def index
    @translations ||= Redis.new
  end

  def create
    I18n.backend.store_translations(params[:locale_form],
                                    { params[:key] => params[:value] },   escape: false)
    redirect_to admin_translations_path, notice: 'Added translations'
  end

  def update
    key = params[:id].gsub('|', '.')
    @translator = Translator[key]
    locale = params[:locale] || I18n.locale
    value = params[:translator][:value]
    @translator.locale = locale
    @translator.value = value
    @translator.save_by_backend!
    respond_to do |format|
      format.json { render json: { value: value } }
    end
  end
end
