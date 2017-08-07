class Admin::VariantsController < AdminController
  before_action :find_product
  before_action :find_variant, only: [:edit, :update, :destroy]

  def index
    @variants = @product.variants.includes(:option_values)
  end

  def new
    @variant = @product.variants.build
    @variant.build_work_spec
  end

  def create
    @variant = @product.variants.build(variant_params)
    if @variant.save
      redirect_to admin_product_model_variants_path(@product)
    else
      flash.now[:error] = @variant.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @variant.update(variant_params)
      redirect_to admin_product_model_variants_path(@product)
    else
      flash.now[:error] = @variant.errors.full_messages
      render :edit
    end
  end

  def destroy
    @variant.destroy
    redirect_to admin_product_model_variants_path(@product)
  end

  private

  def find_product
    @product = ProductModel.includes(:translations, option_types: :option_values).find_by(slug: params[:product_model_id])
  end

  def find_variant
    @variant = Variant.find(params[:id])
  end

  def variant_params
    params.require(:variant).permit(option_value_ids: [],
                                    work_spec_attributes: [:name, :description, :width, :height, :dpi, :background_image,
                                                           :shape, :alignment_points, :padding_top, :padding_right,
                                                           :padding_bottom, :padding_left, :background_color, :dir_name,
                                                           :placeholder_image, :enable_white, :auto_imposite, :watermark,
                                                           :print_image_mask, :enable_back_image, :overlay_image,
                                                           :enable_composite_with_horizontal_rotation,
                                                           :create_order_image_by_cover_image, :id])
  end
end
