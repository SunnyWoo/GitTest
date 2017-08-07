class Print::OrderItemsController < PrintController
  def index
    @model = ProductModel.find(params[:product_model_id])
    @print_items = PrintItem.ransack(order_item_order_aasm_state_eq: 'paid', aasm_state_eq: 'pending', model_id_eq: @model.id).result
  end

  def show
    @print_item = PrintItem.find(params[:id])
    render layout: false
  end

  def sublimate
    authorize PrintItem, :sublimate?
    if params[:order_item_id].split(',').size > 1
      print_items = PrintItem.find(params[:order_item_id].split(','))
      print_items.each do |print_item|
        print_item.sublimate! if print_item.printed?
      end
    else
      print_item = PrintItem.find(params[:order_item_id])
      print_item.sublimate! if print_item.printed?
    end
    respond_to do |format|
      format.html { redirect_to print_sublimate_path }
      format.json { render json: { status: 'success', message: '修改成功！' }, status: 200 }
    end
  end

  def print
    authorize PrintItem, :print?
    @print_item = PrintItem.find(params[:id])
    if @print_item.pending?
      @print_item.upload!
      log_with_print_channel current_factory
      current_factory.create_activity(:single_file_upload,
                                      message: "print_item_id: #{@print_item.id}", print_item_id: @print_item.id)
      UploadPrinterWorker.perform_async(@print_item.id, current_factory.ftp_gateway.id)
      render json: { url: stamp_print_order_item_path(@print_item) }
    else
      head :bad_request
    end
  end

  def print_all
    authorize PrintItem, :print?
    if !params[:product_model_id].present?
      redirect_to print_print_path, flash: { error: 'Print all error.' }
    else
      print_item_ids = []
      search = { order_item_order_aasm_state_eq: 'paid', aasm_state_eq: 'pending' }
      search = search.merge(model_id_eq: params[:product_model_id]) if params[:product_model_id].present?
      print_itmes = PrintItem.ransack(order_item_order_aasm_state_eq: 'paid',
                                     aasm_state_eq: 'pending', model_id_eq: params[:product_model_id]).result
      print_itmes.each do |print_item|
        if print_item.pending?
          print_item_ids << print_item.id
          print_item.upload!
        end
      end
      log_with_print_channel current_factory
      current_factory.create_activity(:all_file_upload,
                                      message: "print_item_ids: #{print_item_ids.join(',')}",
                                      print_item_ids: print_item_ids)
      UploadMultiPrinterWorker.perform_async(print_item_ids, current_factory.ftp_gateway.id)
      redirect_to print_print_path, flash: { notice: '整批上傳中...' }
    end
  end

  def stamp
    @print_item = PrintItem.find(params[:id])
    if @print_item.uploading?
      render json: { status: 'uploading...!' }
    elsif @print_item.printed?
      render json: { status: 'Done!' }
    else
      render json: { status: 'Unknown!' }
    end
  end
end
