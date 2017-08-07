class Admin::B2bOrdersController < AdminController
  def stickers
  end

  def create_stickers
    excel = params[:excel]
    StickersWorker.perform_async(excel.path,
                                 File.extname(excel.original_filename).delete('.'),
                                 params[:images_zip].try(:path),
                                 params[:email])
    redirect_to :back, notice: '处理完成后会将贴纸寄送到您填写的邮件'
  end
end
