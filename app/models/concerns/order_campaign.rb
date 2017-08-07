# For CN Campaign waterpackage
# 活動結束後移除
module OrderCampaign
  extend ActiveSupport::Concern

  included do
    # redis-object setting
    list :payload
    value :product_key
  end

  def enqueue_create_waterpackage_worker
    CreateWaterpackageWorker.perform_async(id)
  end
end
