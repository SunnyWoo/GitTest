class Admin::WorkTemplatesController < AdminController
  before_action :find_work_spec
  before_action :find_work_template, only: [:edit, :update, :destroy]

  def index
    @work_templates = @work_spec.templates
  end

  def new
    @work_template = @work_spec.templates.build
  end

  def create
    @work_template = @work_spec.templates.build(work_template_params)
    if @work_template.save
      @work_template.serialize_masks(work_template_masks_params)
      redirect_to admin_product_model_work_spec_work_templates_path
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @work_template.update_attributes(work_template_params)
      @work_template.serialize_masks(work_template_masks_params)
      redirect_to admin_product_model_work_spec_work_templates_path
    else
      render action: :edit
    end
  end

  def destroy
    @work_template.destroy
    redirect_to admin_product_model_work_spec_work_templates_path
  end

  private

  def find_work_spec
    @work_spec = WorkSpec.find(params[:work_spec_id])
    @product_model = @work_spec.product
  end

  def find_work_template
    @work_template = @work_spec.templates.find(params[:id])
  end

  def work_template_params
    params.require(:work_template).permit(:aasm_state, :overlay_image, :background_image)
  end

  def work_template_masks_params
    params[:work_template][:masks].values
  end
end
