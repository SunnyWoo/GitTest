class Admin::HeaderLinksController < Admin::ResourcesController
  def index
    @resources = model_class.root.page(params[:page])
  end

  def new
    super
    @resource.parent_id = params[:parent_id].to_i if params[:parent_id].present?
    I18n.available_locales.each do |locale|
      @resource.translations.build(locale: locale)
    end
  end

  def edit
    super
    @resource.build_missing_locale_set
    @resource.tags.each(&:build_missing_locale_set)
  end

  def destroy
    @header_link = model_class.find(params[:id])
    @header_link.destroy
    flash[:error] = @header_link.errors.full_messages if @header_link.errors.size > 0
    redirect_to :back
  end

  def rows
    @header_link = HeaderLink.find(params[:id])
    @columns = @header_link.children.unscope(:order).order(row: :asc)
  end

  def sort
    @header_links = HeaderLink.root
  end

  def update_position
    @header_link = HeaderLink.find(params[:id])
    if @header_link.set_list_position(params[:position])
      render json: { status: 'ok', message: 'Update Success!' }
    else
      render json: { status: 'error', message: @header_link.errors.full_messages }
    end
  end
end
