class Webapi::SearchController < WebapiController
  # Search public work
  #
  # url - /webapi/search/works
  # RESTful - get
  #
  # Get Example
  #  get  /webapi/search/works?name=cute&page=1
  #
  # Return Example
  #  {
  #    "works": [
  #      {
  #        "id": 1,
  #        "uuid": "d262005a-5828-11e4-88b2-3c15c2d24fd8",
  #        "name": "work name",
  #        "order_image": {
  #          "thumb": null,
  #          "normal": null
  #        },
  #        "username": null,
  #        "price": [
  #          {
  #            "USD": 99.9
  #          }
  #        ]
  #      }
  #    ],
  #    "meta": {
  #      "current_page": 1,
  #      "per_page": 30,
  #      "total_entries": 1,
  #      "total_pages": 1
  #    }
  #  }
  #
  # @param name [String] 要搜尋Work name 的文字
  #
  # @return [json] status 200

  def works
    search = Work.is_public.ransack(name_cont: params[:name])
    @result = search.result.paginate(page: params[:page], per_page: params[:per_page])
    render json: @result, each_serializer: Webapi::WorksSerializer, root: :works, meta: {
      current_page: @result.current_page,
      per_page: @result.per_page,
      total_entries: @result.total_entries,
      total_pages: @result.total_pages
    }
  end
end
