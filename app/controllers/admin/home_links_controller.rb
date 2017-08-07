class Admin::HomeLinksController < Admin::ResourcesController
  def index
    @resources = model_class.all.page(params[:page])
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

  def sort
    @resource = model_class.find(params[:id])
    if @resource.respond_to? params[:sort]
      @resource.send params[:sort]
      redirect_to admin_home_links_path
    else
      render_404
    end
  end
end
