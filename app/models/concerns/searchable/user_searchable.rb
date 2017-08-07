# 自訂 User Elasticsearch 規則
module Searchable::UserSearchable
  extend ActiveSupport::Concern

  included do
    after_commit(on: :create) { ElasticsearchIndexer.index(self) if normal? }
    after_commit(on: :update) { ElasticsearchIndexer.index(self) if normal? }
    after_commit(on: :destroy) { ElasticsearchIndexer.delete(self) }

    # 定義欄位 analyzer 才可搜尋 斷詞 中文
    mappings  do
      indexes :email, type: 'string', analyzer: 'cjk'
      indexes 'profile.name', type: 'string', analyzer: 'cjk'
    end
  end

  # 建立index 時回傳的json
  def as_indexed_json(_options = {})
    { 'id' => id, 'email' => email, 'profile' => profile }
  end

  module ClassMethods
    # search 方法
    def search_by_elasticsearch(query, page = 1, per_page = 30)
      __elasticsearch__.search(
        query: {
          bool: {
            should: [
              {
                multi_match: {
                  query: query,
                  fields: %w(email name)
                }
              }
            ]
          }
        }
      ).page(page).per_page(per_page).records
    end
  end
end
