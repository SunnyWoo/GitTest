namespace :standardized_work do
  task check_and_async_order_image: :environment do
    StandardizedWork.find_each do |sw|
      next if sw.order_image.present?
      next unless work = Work.find_by(uuid: sw.uuid)
      work.previews.each do |work_preview|
        sw.previews.create key: work_preview.key, image: work_preview.image
      end
    end
  end
end
