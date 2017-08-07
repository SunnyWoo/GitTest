class UpdateWorkTagWorker
  include Sidekiq::Worker

  def perform(product_model_id, added_tag_ids, removed_tag_ids)
    ProductModel.update_works_tag(product_model_id, added_tag_ids, removed_tag_ids)
  end
end
