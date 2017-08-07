class Admin::ProductCodesController < AdminController
  def index
    @code_types_collection = Admin::ProductCodeForm.code_types_collection
    @new_code = Admin::ProductCodeForm.new
  end

  def create
    record = Admin::ProductCodeForm.new(product_code_params).save!
    if record.valid?
      redirect_to admin_product_codes_path, notice: 'success'
    else
      redirect_to admin_product_codes_path, alert: record.errors.full_messages.join(',')
    end
  end

  def edit
    @product_code_form = Admin::ProductCodeForm.new(code_type: params[:code_type], id: params[:id])
    @product_code_form.description = @product_code_form.member.description
  end

  def update
    Admin::ProductCodeForm.new(product_code_params.slice(:code_type, :description).merge(id: params[:id])).update!
    redirect_to admin_product_codes_path, notice: 'success'
  end

  def exporting
  end

  def export
    if params[:export_type] == 'all'
      content = ExportProductCodeService.export_all
    else
      content = ExportProductCodeService.export_by_time(params[:q][:created_at_gteq], params[:q][:created_at_lteq])
    end
    respond_to do |format|
      format.xlsx do
        send_data content, type: 'application/xlsx', disposition: file_disposition('商品编码', 'xlsx')
      end
    end
  end

  private

  def product_code_params
    params.require(:admin_product_code_form).permit(:code_type, :code, :description)
  end
end
