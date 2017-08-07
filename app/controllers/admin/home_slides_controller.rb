class Admin::HomeSlidesController < Admin::ResourcesController
  def index
    params[:q] ||= {}
    params[:q][:is_enabled_eq] ||= true
    @search = model_class.ransack(params[:q])
    @resources = @search.result(distinct: true).order('id DESC').page(params[:page] || 1)
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
