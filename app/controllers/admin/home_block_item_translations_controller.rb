class Admin::HomeBlockItemTranslationsController < AdminController
  def update_pic
    @item = HomeBlockItem.find(params[:block_item_id])
    create_empty_translations if @item.translations.blank?
    if @item.translations.find_by!(locale: params[:locale_attr]).update(pic: params[:pic])
      render json: { message: 'ok' }, status: 200
    else
      render json: { message: 'no' }, status: 400
    end
  end

  protected

  def create_empty_translations
    I18n.available_locales.each do |locale|
      @item.translations.create locale: locale
    end
  end
end
