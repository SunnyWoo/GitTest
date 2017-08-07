class Print::ShelvesController < PrintController
  before_action :authorize_action, only: [:new, :edit, :changing, :stocking, :moving]
  before_action :check_change_actions, only: %i(changing change)
  before_action :find_categories, only: [:new, :edit]

  def index
    q = params[:q] || {}
    q.merge!(quantity_not_eq: 0)
    @q = current_factory.shelves.ransack(q)
    @shelves = @q.result.decorate
    respond_to do |format|
      format.html
      format.csv do
        authorize Shelf, :export_csv?
        send_data mark_csv_data(PrintService.export_shelves_csv(@shelves)),
                  disposition: file_disposition(Shelf.model_name.human, 'csv')
      end
    end
  end

  def new
    authorize Shelf, :create?
    @shelf = Shelf.new
  end

  def create
    authorize Shelf, :create?
    @shelf = current_factory.shelves.new(create_shelf_params)
    if @shelf.save
      redirect_to new_print_shelf_path
    else
      render :new
    end
  end

  def show
    @shelf = current_factory.shelves.find(params[:id]).decorate
  end

  def edit
    authorize Shelf, :update?
    @shelf = current_factory.shelves.find(params[:id]).decorate
  end

  def update
    authorize Shelf, :update?
    @shelf = current_factory.shelves.find(params[:id])
    if @shelf.update(create_shelf_params)
      redirect_to print_shelves_path
    else
      redirect_to edit_print_shelf_path(@shelf), alert: @shelf.errors.full_messages
    end
  end

  def changing
    authorize Shelf, :change?
    @storage = Print::StorageForm.new
  end

  def change
    authorize Shelf, :change?
    @storage = Print::StorageForm.new(storage_params)
    @storage.ship_or_allocate
    quantity_before_action = @storage.storage.quantity - @storage.quantity.to_i
    create_shelf_activity(@changing_action, @storage.storage, @storage.quantity.to_i, quantity_before_action)
    redirect_to :back
  end

  def seek
    if params[:shelf_serial].present? && params[:material_serial].present?
      @shelf = current_factory.shelves.ransack(serial_eq: params[:shelf_serial],
                                               material_serial_eq: params[:material_serial]).result.first
    else
      @shelf = current_factory.shelves.find_by(serial: params[:serial])
    end
    render json: { shelf: @shelf }
  end

  def restoring
    authorize Shelf, :restore?
    @storage = Print::StorageForm.new
  end

  def restore
    authorize Shelf, :restore?
    @storage = Print::StorageForm.new(storage_params)
    @storage.restore
    old_quantity = @storage.storage.quantity - @storage.quantity.to_i
    create_shelf_activity(:restore, @storage.storage, @storage.quantity.to_i, old_quantity)
    redirect_to restoring_print_shelves_path, notice: 'success'
  end

  def stocking
    authorize Shelf, :stock?
    @storage = Print::StorageForm.new
  end

  def stock
    authorize Shelf, :stock?
    @storage = Print::StorageForm.new(storage_params)
    @storage.stock
    old_quantity = 0
    create_shelf_activity(:stock, @storage.storage, @storage.quantity.to_i, old_quantity)
    redirect_to stocking_print_shelves_path
  end

  def adjusting
    authorize Shelf, :adjust?
    @storage_lock = Print::StoragePolicyService.storage_lock?
    @shelves = current_factory.shelves.where.not(material_id: nil).order('serial')
  end

  def adjust
    authorize Shelf, :adjust?
    params[:storage].delete_if { |_key, value| value[:original_quantity] == value[:quantity] }
    params[:storage].each do |key, value|
      shelf = Shelf.update(key, quantity: value[:quantity])
      old_quantity = value[:original_quantity]
      adjust_quantity = value[:quantity].to_i - value[:original_quantity].to_i
      create_shelf_activity(:adjust, shelf, adjust_quantity, old_quantity)
    end
    Print::StoragePolicyService.finish_adjust
    redirect_to print_shelves_path
  end

  def start_adjust
    authorize Shelf, :adjust?
    Print::StoragePolicyService.start_adjust
    redirect_to adjusting_print_shelves_path, notice: '已發起盤點'
  end

  def finish_adjust
    authorize Shelf, :adjust?
    Print::StoragePolicyService.finish_adjust
    redirect_to print_shelves_path, notice: '已取消盤點'
  end

  def moving
    authorize Shelf, :move?
    @storage = Print::StorageForm.new
  end

  def move
    authorize Shelf, :move?
    @storage = Print::StorageForm.new(move_from: params[:move_from],
                                      move_target: params[:move_target],
                                      factory_id: current_factory.id)
    @storage.move
    @storage.move_from.values.each do |from_values|
      quantity = from_values[:quantity].to_i
      old_quantity = from_values[:from_storage].quantity - quantity
      create_shelf_activity(:move_out, from_values[:from_storage], quantity, old_quantity)
    end
    @storage.move_target.values.each do |target_values|
      quantity = target_values[:quantity].to_i
      old_quantity = target_values[:target_storage].quantity - quantity
      create_shelf_activity(:move_in, target_values[:target_storage], quantity, old_quantity)
    end
    redirect_to :back
  end

  def activities
    authorize Shelf, :activities?
    set_default_time_filter
    scoped = Logcraft::Activity.where(trackable_type: 'Shelf', trackable_id: current_factory.shelves.pluck(:id))
    @q = scoped.ransack(params[:q])
    @activities = @q.result.includes(:trackable).order('id DESC')
    respond_to do |format|
      format.html
      format.csv do
        send_data mark_csv_data(PrintService.export_shelf_activities_csv(@activities)),
                  disposition: file_disposition('倉儲貨架紀錄', 'csv')
      end
    end
  end

  private

  def create_shelf_params
    params.require(:shelf).permit(:serial, :category_id)
  end

  def create_shelf_activity(key, shelf, quantity, old_quantity, options = {})
    log_with_print_channel shelf
    options.merge! quantity: quantity, old_quantity: old_quantity, message: params[:message] || storage_params[:message]
    shelf.create_activity(key, options)
  end

  def check_change_actions
    valid_actions = %w(ship allocate)
    fail ParametersInvalidError unless valid_actions.include?(params[:changing_action])
    @changing_action = params[:changing_action]
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

  def find_categories
    @categories = current_factory.shelf_categories.all
  end

  def storage_params
    params.require(:print_storage_form)
      .permit(:shelf_serial, :material_serial, :quantity, :message)
      .merge(factory_id: current_factory.id)
  end

  def authorize_action
    redirect_to print_shelves_path, notice: '正在盘点...' if Print::StoragePolicyService.storage_lock?
  end
end
