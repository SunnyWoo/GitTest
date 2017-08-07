# 主要用來搜尋 跨 index, 並回傳不同 index 的result
class ElasticsearchService
  # search = ElasticsearchService.new(index: 'users,works', fields: 'name', q: '我印').execute
  def initialize(index, fields, q)
    @client = Elasticsearch::Client.new
    @index = index
    @fields = Array(fields)
    @q = q
  end

  #
  #  return example
  #   {
  #            "took" => 3,
  #       "timed_out" => false,
  #         "_shards" => {
  #                "total" => 10,
  #           "successful" => 10,
  #               "failed" => 0
  #       },
  #            "hits" => {
  #               "total" => 2,
  #           "max_score" => 0.047079325,
  #                "hits" => [
  #               [0] {
  #                    "_index" => "works",
  #                     "_type" => "work",
  #                       "_id" => "5399",
  #                    "_score" => 0.047079325,
  #                   "_source" => {
  #                                  "id" => 5399,
  #                                "name" => "我印測試work!",
  #                       "user_username" => "Guest",
  #                               "model" => {
  #                           "name" => "iPhone 6 Cases"
  #                       }
  #                   }
  #               },
  #               [1] {
  #                    "_index" => "users",
  #                     "_type" => "user",
  #                       "_id" => "4190",
  #                    "_score" => 0.047079325,
  #                   "_source" => {
  #                            "id" => 4190,
  #                         "email" => "guest_142234120444@commandp.me",
  #                       "profile" => {
  #                           "name" => " 我印測試 User"
  #                       }
  #                   }
  #               }
  #           ]
  #       }
  #   }
  #
  # @return hash
  def execute
    @client.search index: @index, body: { query: {
          bool: {
            should:[
              {
                multi_match: {
                  query: @q,
                  fields: @fields
                }
              }
            ]
          }
        }
      }
  end
end