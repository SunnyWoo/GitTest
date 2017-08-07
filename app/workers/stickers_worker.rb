class StickersWorker
  include Sidekiq::Worker

  def perform(excel_path, excel_extension, zip_path, email)
    args = {
      excel_path: excel_path,
      excel_extension: excel_extension,
      zip_path: zip_path,
      email: email
    }
    B2bStickerService.new(args).execute
  end
end
