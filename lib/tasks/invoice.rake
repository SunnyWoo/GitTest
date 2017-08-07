namespace :invoice do
  task download_bankpro_file: :environment do
    if Order.invoice_uploading.count > 0 || Order.invoice_uploaded.count > 0
      InvoiceService.download_bankpro_file
    end
  end
end