class Admin::OptionTypesController < AdminController
  def destroy
    OptionValue.find(params[:id]).destroy
    render :back, notice: 'success'
  end
end
