class UploadPrinterWorker
  include Sidekiq::Worker

  def perform(print_item_id, file_gateway_id)
    PrinterUploaderService.new(print_item_id, file_gateway_id).execute
  end
end
