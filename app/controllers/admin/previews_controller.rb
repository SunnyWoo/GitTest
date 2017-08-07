class Admin::PreviewsController < AdminController
  def destroy
    @preview = Preview.find(params[:id])
    @preview.destroy
  end
end
