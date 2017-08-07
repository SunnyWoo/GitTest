class Print::ReceptionsController < PrintController

  before_action :find_print_item

  def new
    authorize PrintItem, :receive?
    @form = Print::ReceptionForm.new(@print_item)
  end

  def create
    authorize PrintItem, :receive?
    @form = Print::ReceptionForm.new(@print_item)
    @form.attributes = reception_params
    if @form.save
      redirect_to :back, notice: 'Update Sucessfully'
    else
      flash[:error] = @form.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  private

  def find_print_item
    @print_item = PrintItem.find(params[:print_item_id])
  end

  def reception_params
    params.require(:reception).permit(:serial, :description, :state)
  end
end
