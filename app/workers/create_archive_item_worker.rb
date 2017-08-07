class CreateArchiveItemWorker
  include Sidekiq::Worker
  sidekiq_options queue: :create_archive_item

  def perform(order_item_id)
    return unless OrderItem.find_by(id: order_item_id)
    OrderItem.find(order_item_id).whodunnit('CreateArchiveItemWorker') do |item|
      unless item.itemable.archived?
        archived_work = item.itemable.last_archive
        fail ActiveRecord::ActiveRecordError, 'ArchivedWork not persisted' unless archived_work.persisted?
        item.update!(itemable: archived_work)
      end
    end
  end
end
