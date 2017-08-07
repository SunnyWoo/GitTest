class Admin::AssetPackageCategoriesController < Admin::ResourcesController
  def index
    search_params = params[:q] || { available_eq: true }
    @search = model_class.with_translations(I18n.locale).ransack(search_params)
    @categories = @search.result.paginate(page: params[:page], per_page: 20)
    respond_to do |f|
      f.html
      f.json { render 'api/v3/asset_package_categories/index' }
    end
  end

  def new
    super
    I18n.available_locales.each do |locale|
      @resource.translations.build(locale: locale)
    end
  end

  def edit
    super
    @resource.build_missing_locale_set
  end
end
