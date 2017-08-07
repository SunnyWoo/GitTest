class Admin::MobileComponentsController < AdminController
  before_action :find_mobile_page
  before_action :find_mobile_component, except: %w(new create)
  before_action :prepare_for_mobile_component, only: %w(new create edit update)

  def new
  end

  def edit
  end

  def update
    if @mobile_component.update(mobile_component_params)
      redirect_to url_for([:edit, :admin, @mobile_page])
    else
      flash[:error] = @mobile_component.errors.full_messages
      render :edit
    end
  end

  def update_position
    if @mobile_component.set_list_position(params[:position])
      render json: { status: 'ok', message: 'Update Success!' }
    else
      render json: { status: 'error', message: @mobile_page.errors.full_messages }
    end
  end

  def create
    mobile_component = @mobile_page.mobile_components.new(mobile_component_params)
    if mobile_component.save
      flash[:notice] = '元件新增成功'
    else
      flash[:error] = mobile_component.errors.full_messages
    end
  end

  def destroy
    if @mobile_component.destroy
      flash[:notice] = '元件刪除成功'
    else
      flash[:error] = @mobile_component.errors.full_messages
    end
  end

  private

  def find_mobile_page
    @mobile_page = MobilePage.find(params[:mobile_page_id])
  end

  def find_mobile_component
    @mobile_component = @mobile_page.mobile_components.find(params[:id])
  end

  def prepare_for_mobile_component
    @campaigns = MobilePage.campaign_page.enabled.pluck(:title, :id)
    @price_tiers = PriceTier.all.map { |p| ["Tier #{p.tier} / TWD #{p.prices['TWD']}", p.id] }
    @media_types = %w(A B)
    @product_categories = ProductCategory.includes(:translations).available.map { |c| ["#{c.name} / #{c.key}", c.key] }
    @product_models = ProductModel.includes(:translations).available.map { |c| ["#{c.name} / #{c.key}", c.key] }
    @designers = Designer.all.pluck(:display_name, :id)
    @tags = Tag.all.pluck(:name, :id)
    @collections = Collection.all.pluck(:name, :id)
    @tab_categories = MobileComponent::TAB_CATEGORIES
  end

  def mobile_component_params
    params.require(:mobile_component).permit(:mobile_page_id, :key, :image, :_destroy, :id, :position,
                                             contents: MobileComponent::CONTENT_KEYS.keys,
                                             sub_components_attributes: [:parent_id, :image, :_destroy, :id, :position,
                                                                         contents: MobileComponent::CONTENT_KEYS.keys])
  end
end
