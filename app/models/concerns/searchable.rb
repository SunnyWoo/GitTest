module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    index_name [Rails.env, model_name.collection.gsub(%r{/}, '-')].join('_')
  end

  module ClassMethods
    def initialize_elasticsearch
      __elasticsearch__.client.indices.create(
        index: index_name,
        body: { settings: settings.to_hash, mappings: mappings.to_hash }
      )
      __elasticsearch__.create_index! force: true
    rescue => e
      # do nothing
      Rails.logger.warn e.message
    end

    def re_initialize_elasticsearch
      __elasticsearch__.client.indices.delete index: index_name
      initialize_elasticsearch
    end

    def es_health_check
      __elasticsearch__.client.cluster.health
    end

    def sorted_search(sort_by, filter_name = '')
      case sort_by
      when 'new'
        { id: { order: 'desc' } }
      when 'popular'
        { impressions_count: { order: 'desc' } }
      when 'tag'
        { "tag_positions.#{filter_name}": { order: 'asc', ignore_unmapped: true }, id: { order: 'desc' } }
      when 'collection'
        { "collection_positions.#{filter_name}": { order: 'asc', ignore_unmapped: true }, id: { order: 'desc' } }
      when 'price_asc'
        { 'prices.TWD': { order: 'asc' } }
      when 'price_desc'
        { 'prices.TWD': { order: 'desc' } }
      else
        {}
      end
    end
  end
end
