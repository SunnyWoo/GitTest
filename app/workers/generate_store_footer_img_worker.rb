class GenerateStoreFooterImgWorker
  include Sidekiq::Worker

  def perform(store_id)
    Store.find(store_id).generate_store_footer_img
  end
end
