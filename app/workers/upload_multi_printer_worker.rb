class UploadMultiPrinterWorker
  include Sidekiq::Worker

  def perform(print_item_ids, file_gateway_id)
    PrintItem.upload_multi_file_to_printer(print_item_ids, file_gateway_id)
  end
end
