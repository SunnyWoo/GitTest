class Imposition::ImpositionUploader
  include Sidekiq::Worker
  sidekiq_options queue: :adobe, retry: 50

  sidekiq_retry_in { 10 + rand(1..10) }

  def perform(factory_id, model_id, item_ids, upload_path, serial_number)
    factory = Factory.find(factory_id)
    model = ProductModel.find(model_id)
    items = PrintItem.find(item_ids)

    # 暫時拿掉避免重複上傳的檢查
    # printed_items = items.find_all { |item| item.printed? || item.sublimated? || item.onboard? }
    # if printed_items.any?
    #   fail "unexpected printed items: #{printed_items.map(&:id).join(', ')}"
    # end

    printed_items = items.find_all { |item| item.printed? || item.sublimated? || item.onboard? }
    return if printed_items.any?

    imposition = model.imposition || Imposition::Niflheim.instance
    filenames = imposition.build_printable(items)
    filenames = Array(filenames) unless filenames.is_a?(Array)
    filenames.each_with_index do |filename, index|
      next unless filename
      begin
        upload_filename = if filename =~ %r{tmp/white-}
                            "white-" + upload_filename(model, items, serial_number, index, filename)
                          elsif filename =~ /back_image/
                            "back_image-" + upload_filename(model, items, serial_number, index, filename)
                          else
                            upload_filename(model, items, serial_number, index, filename)
                          end
        factory.ftp_gateway.upload(filename, path: upload_path, filename: upload_filename)
      ensure
        File.delete(filename) if filename && File.exist?(filename)
        fail if $ERROR_INFO
      end
    end

    items.each(&:print!) rescue nil # You only need to click once, fool!
  end

  # 此處命名規則由PM有定義一套相關的規則
  def upload_filename(model, items, imposition_serial_number, file_serial_number, filename)
    case model.imposition
    when Imposition::Vanaheim, Imposition::Niflheim
      # 該拼板每張拼板只有一個作品
      "#{items.first.timestamp_no}-x#{imposition_serial_number}-#{file_serial_number}#{File.extname(filename)}"
    when Imposition::Alfheim
      "#{Time.zone.now.strftime('%y%m%d_%H%M%S')}-x#{imposition_serial_number}-#{file_serial_number}#{File.extname(filename)}"
    else
      "#{model.key}-x#{imposition_serial_number}-#{file_serial_number}#{File.extname(filename)}"
    end
  end
end
