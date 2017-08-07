# Modified from this example
# https://github.com/elastic/elasticsearch-rails/tree/master/elasticsearch-model#asynchronous-callbacks
class ElasticsearchIndexer
  include Sidekiq::Worker
  sidekiq_options retry: false

  Client = Elasticsearch::Client.new hosts: Settings.elasticsearch

  # 這裡不用 GID 是因為 model 可能已經被刪除了
  def perform(operation, model_class, model_id)
    logger.debug [operation, "ID: #{model_id}"]
    model_class = model_class.constantize
    index_name = model_class.index_name
    type_name = model_class.model_name.singular

    case operation.to_s
    when /index/
      model = model_class.find(model_id)
      Client.index index: index_name,
                   type: type_name,
                   id: model.id,
                   body: model.as_indexed_json
    when /delete/
      begin
        Client.delete index: index_name, type: type_name, id: model_id
      rescue
        Rails.logger.warn "Cannot delete Elasticsearch document for #{index_name}.#{type_name} id: #{model_id}"
      end
    else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end

  def self.operate(operation, model)
    perform_async(operation, model.class.name, model.id)
  end

  def self.index(model)
    operate('index', model)
  end

  def self.delete(model)
    operate('delete', model)
  end
end
