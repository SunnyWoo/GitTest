# 自訂 Work Elasticsearch 規則
module Searchable::WorkSearchable
  extend ActiveSupport::Concern

  included do
    # 定義欄位 analyzer 才可搜尋 斷詞 中文
    mappings do
      indexes :name, type: 'string', analyzer: 'cjk'
      indexes :product_globalize_name, type: 'string', analyzer: 'cjk'
      indexes :user_display_name, type: 'string', analyzer: 'cjk'
      indexes :product_available, type: 'string'
      indexes :product_key, type: 'string', analyzer: 'cjk'
      indexes :category_id, type: 'long', analyzer: 'cjk'
      indexes :all_tags, type: 'string', analyzer: 'cjk'
      indexes :collection_names, type: 'string', analyzer: 'cjk'
      indexes :tag_names, type: 'string', analyzer: 'cjk'
    end

    # custom callback
    after_commit on: [:create, :update] do
      if need_indexed?
        ElasticsearchIndexer.index(self)
      else
        ElasticsearchIndexer.delete(self)
      end
    end

    after_commit on: :destroy do
      ElasticsearchIndexer.delete(self) if is_public?
    end

    delegate :key, :available, :globalize_name, to: :product, prefix: true
  end

  def need_indexed?
    is_public? || try(:redeem?) && product_available
  end

  # 建立index 時回傳的json
  def as_indexed_json(*)
    as_json(
      methods: [
        :user_display_name,
        :product_globalize_name,
        :product_available,
        :work_type,
        :product_key,
        :category_id,
        :all_tags,
        :tag_names,
        :collection_names,
        :collection_positions,
        :tag_positions,
        :prices,
        :user_type,
        :user_id,
        :cradle
      ],
      only: [:id, :name, :model_id, :impressions_count, :category_id, :aasm_state]
    )
  end

  module ClassMethods
    # import index to elasticsearch
    def import_elasticsearch
      find_each do |work|
        work.__elasticsearch__.index_document if work.need_indexed?
      end
    end

    def search_by_id(id)
      __elasticsearch__.search(
        query: {
          bool: {
            must: [{ term: { id: id } }]
          }
        }
      )
    end

    # search 方法
    def search_by_elasticsearch(query, page = 1, per_page = 30)
      __elasticsearch__.search(
        query: {
          bool: {
            must: [
              {
                multi_match: {
                  query: query,
                  fields: %w(_id name user_display_name product_globalize_name)
                }
              }
            ]
          }
        }
      ).page(page).per_page(per_page).records
    end

    # arge[:query] - 要被搜尋的文字
    # arge[:model_id] - 要被搜尋的 model id
    # arge[:category_id] - 要被搜尋的 category_id
    # arge[:user_name] - 要被搜尋的 user_display_name
    def search_for_website_search(args = {}, page = 1, per_page = 30)
      # 定義需被搜尋的條件
      must = [
        { term: { product_available: 'true' } },
        { term: { cradle: 'commandp' } }
      ]
      must_not = {}
      must << { term: { work_type: 'is_public' } } if class_name == 'Work'
      must << { term: { aasm_state: 'published' } } if class_name == 'StandardizedWork'
      must_not = { term: { user_type: 'store' } } if class_name == 'StandardizedWork'

      # 定義多個欄位搜尋
      if args[:query]
        must << {
          multi_match: {
            query: args[:query],
            type: 'best_fields',
            fields: %w(name user_display_name product_globalize_name all_tags) }
        }
      end

      # 指定 username
      if args[:user_name]
        must << {
          query_string: {
            default_field: 'user_display_name',
            query: args[:user_name]
          }
        }
      end

      if args[:product_key]
        must << {
          query_string: {
            default_field: 'product_key',
            query: args[:product_key]
          }
        }
      end

      # 指定 tag
      if args[:tag]
        must << {
          query_string: {
            default_field: 'all_tags',
            query: args[:tag]
          }
        }
      end

      # 指定 tag
      if args[:tag_name]
        must << {
          query_string: {
            default_field: 'tag_names',
            query: args[:tag_name]
          }
        }
      end

      # 指定 tag
      if args[:collection_name]
        must << {
          query_string: {
            default_field: 'collection_names',
            query: args[:collection_name]
          }
        }
      end

      # 指定 model_id, 支援多個 model_id 使用 , 隔開 ex: '1,2,3'
      must << { terms: { model_id: args[:model_id].split(',') } } if args[:model_id]

      # 指定 category_id, 支援多個 category_id 使用 , 隔開 ex: '1,2,3'
      must << { terms: { category_id: args[:category_id].split(',') } } if args[:category_id]

      # 指定 sort(order)
      # recommend为使用后台设置的推荐排序方式
      if args[:sort] == 'recommend'
        recommend_sort = RecommendSort.find_by(design_platform: args[:design_platform]).sort
        args[:sort] = recommend_sort
        sort = sorted_search(args[:sort])
      elsif args[:tag_name].present? && args[:sort].blank?
        sort = sorted_search('tag', args[:tag_name])
      elsif args[:collection_name].present? && args[:sort].blank?
        sort = sorted_search('collection', args[:collection_name])
      else
        sort = sorted_search(args[:sort])
      end

      bool = { must: must }
      bool[:must_not] = must_not if must_not.present?

      query = if args[:sort].present? && args[:sort] == 'random'
                {
                  function_score: {
                    query: { bool: bool },
                    random_score: {}
                  }
                }
              else
                { bool: bool }
              end

      __elasticsearch__.search(
        query: query,
        sort: sort,
      ).paginate(page: page, per_page: per_page).records
    end
  end
end
