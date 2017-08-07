class Print::ShelfMaterialsController < PrintController
  before_action :find_material, only: [:show, :edit, :update, :adjusting, :adjust]

  def index
    authorize ShelfMaterial, :index?
    @q = current_factory.shelf_materials.ransack(params[:q])
    @shelf_materials = @q.result.decorate
    respond_to do |format|
      format.html
      format.csv do
        send_data mark_csv_data(PrintService.export_shelf_materials_csv(@shelf_materials)),
                  disposition: file_disposition(ShelfMaterial.model_name.human, 'csv')
      end
    end
  end

  def new
    authorize ShelfMaterial, :create?
    @shelf_material = ShelfMaterial.new
  end

  def create
    authorize ShelfMaterial, :create?
    @shelf_material = current_factory.shelf_materials.new(material_params)
    if @shelf_material.save
      redirect_to new_print_shelf_material_path
    else
      render :new
    end
  end

  def show
    authorize ShelfMaterial, :index?
    @shelves = current_factory.shelves.where(material_id: @shelf_material.id).decorate
  end

  def edit
    authorize ShelfMaterial, :update?
  end

  def update
    authorize ShelfMaterial, :update?
    if @shelf_material.update(material_params)
      redirect_to print_shelf_materials_path
    else
      render :edit
    end
  end

  def seek
    @shelf_material = current_factory.shelf_materials.find_by(serial: params[:serial])
    render json: { shelf_material: @shelf_material }
  end

  def stocking
    authorize ShelfMaterial, :stock?
    @shelf_material = ShelfMaterial.new
  end

  def stock
    authorize ShelfMaterial, :stock?
    stock_quantity = params[:shelf_material][:quantity].to_i
    shelf_material = current_factory.shelf_materials.find_by(serial: params[:shelf_material][:serial])
    if shelf_material
      shelf_material.stock!(stock_quantity)
      old_quantity = shelf_material.quantity - stock_quantity
      create_material_activity(:stock, shelf_material, stock_quantity, old_quantity)
      redirect_to stocking_print_shelf_materials_path, notice: 'success'
    else
      redirect_to stocking_print_shelf_materials_path, error: 'serial not exist'
    end
  end

  def adjusting
    authorize ShelfMaterial, :adjust?
  end

  def adjust
    authorize ShelfMaterial, :adjust?
    old_quantity = @shelf_material.quantity
    if @shelf_material.update(quantity: params[:shelf_material][:quantity].to_i)
      adjust_quantity = params[:shelf_material][:quantity].to_i - old_quantity
      create_material_activity(:adjust, @shelf_material, adjust_quantity, old_quantity)
      redirect_to print_shelf_materials_path
    else
      render :adjusting
    end
  end

  def activities
    authorize ShelfMaterial, :activities?
    set_default_time_filter
    scoped = Logcraft::Activity.where(trackable_type: 'ShelfMaterial',
                                      trackable_id: current_factory.shelf_materials.pluck(:id))
    @q = scoped.ransack(params[:q])
    @activities = @q.result.includes(:trackable).order('id DESC')
    respond_to do |format|
      format.html
      format.csv do
        send_data mark_csv_data(PrintService.export_shelf_materials_activities_csv(@activities)),
                  disposition: file_disposition('倉儲物料紀錄', 'csv')
      end
    end
  end

  private

  def find_material
    @shelf_material = current_factory.shelf_materials.find(params[:id])
  end

  def material_params
    params.require(:shelf_material).permit(:serial, :name, :image, :safe_minimum_quantity)
  end

  def create_material_activity(key, material, quantity, old_quantity, options = {})
    log_with_print_channel material
    options.merge! quantity: quantity, old_quantity: old_quantity, message: params[:message]
    material.create_activity(key, options)
  end

  def set_default_time_filter
    params[:q] ||= {}
    if params[:q][:created_at_lteq].blank?
      params[:q][:created_at_lteq] = (Time.zone.now + 1.minutes).strftime('%F %R')
    end
    if params[:q][:created_at_gteq].blank?
      params[:q][:created_at_gteq] = (Time.zone.parse(params[:q][:created_at_lteq]) - 60.days).strftime('%F %R')
    end
  end
end
