class Print::NotesController < PrintController
  before_action :find_order

  def index
    @notes = @order.notes
  end

  def new
    authorize Note, :create?
    @note = @order.notes.build
  end

  def create
    authorize Note, :create?
    @note = @order.notes.build(print_permitted_params.note)
    @note.user = current_factory_member
    @note.save!
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    authorize Note, :update?
    @note = @order.notes.find(params[:id])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    authorize Note, :update?
    @note = @order.notes.find(params[:id])
    @note.update_attributes(print_permitted_params.note)
    respond_to do |f|
      f.js
    end
  end

  private

  def find_order
    @order = Order.find(params[:order_id])
  end
end
