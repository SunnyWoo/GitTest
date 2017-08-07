class ImportOrdersWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(order_import_id, method)
    order_import = ImportOrder.find(order_import_id)
    order_import.send(method)
  end

  class << self
    def generate_orders_by_file(order_import_id)
      perform_async(order_import_id, :generate_orders)
    end

    def generate_orders_by_failed(order_import_id)
      perform_async(order_import_id, :failed_retry)
    end
  end
end
