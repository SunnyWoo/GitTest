class Api::V1::WorksController < ApiController
  include WorksSorter

  # Public: Work list
  #
  # url - /api/works
  #
  # RESTful - GET
  #
  # Get Example
  #   /api/works
  #   /api/works?page=2
  #   /api/works?feature=true&page=1&per_page=10
  #   /api/works?feature=true&page=1&per_page=10&model_id=1
  #   /api/works?feature=true&page=1&per_page=10&sort=popular
  #   /api/works?feature=true&page=1&per_page=10&sort=popular&model_id
  #   /api/works?user_username=commandp
  #   /api/works?model_key=iphone_6_case
  # Return Example
  #   {
  #     "works": [
  #       {
  #         "uuid": "e91aa790-76da-11e4-8fe8-3c15c2d24fd8",
  #         "finished": false,
  #         "cover_image": {
  #           "thumb": "\/uploads\/work\/cover_image\/1\/c597a393af16e0ae65e7028bdd1a5482_test.jpg?v=1417164331",
  #           "normal": "\/uploads\/work\/cover_image\/1\/a7078b6ab649f0987e9ef1d80df98e47_test.jpg?v=1417164331",
  #           "shop": null
  #         },
  #         "name": "work name",
  #         "model": "iphone8",
  #         "category": {
  #           "id": 1,
  #           "key": "product_category_1",
  #           "name": "Name_1",
  #           "modle": {
  #             "id": 1,
  #             "key": "key1",
  #             "name": "iphone8"
  #           }
  #         },
  #         "editable": false,
  #         "feature": false,
  #         "user": {
  #           "id": 1,
  #           "email": "user1@commandp.me",
  #           "avatar": {
  #             "thumb": "\/assets\/img_fbdefault.png?v=1417164331",
  #             "normal": "\/assets\/img_fbdefault.png?v=1417164331"
  #           },
  #           "username": null,
  #           "role": "normal"
  #         }
  #       }
  #     ],
  #     "meta": {
  #       "current_page": 1,
  #       "per_page": 20,
  #       "total_pages": 1,
  #       "total_entries": 1
  #     }
  #   }
  #
  # @param feature [String] true or false or all
  # @param page [Integer] page number
  # @param per_page [Integer] per_page number
  # @param model_id [Integer] product_model's id
  # @param model_key [Staging] product_model's key
  # @param sort [String] new, random, or popular
  # @param user_username [String] Work user name
  # @return [JSON] status 200

  def index
    q = {}
    q.merge!(model_id_eq: params[:model_id]) if params[:model_id]
    q.merge!(product_key_eq: params[:model_key]) if params[:model_key] # TODO: just fucking remove me
    q.merge!(product_key_eq: params[:product_key]) if params[:product_key]
    q.merge!(feature_eq: params[:feature]) if params[:feature] && params[:feature] != 'all'
    q.merge!(user_of_Designer_type_username_cont: params[:user_username]) if params[:user_username]
    @works = Work.is_public.ransack(q).result
    @works = sorted_works(params[:sort], @works).paginate(page: params[:page], per_page: params[:per_page])
    render json: @works, each_serializer: WorkSerializer, meta: {
      'current_page' => @works.current_page,
      'per_page' => @works.per_page,
      'total_pages' => @works.total_pages,
      'total_entries' => @works.total_entries
    }
    fresh_when(etag: @works)
  end

  # Public: Work show
  #
  # url - /api/works/:work_uuid
  #
  # RESTful - GET
  #
  # Get Example
  #   /api/works/:work_uuid
  #
  # Return Example
  #   {
  #     "id": 1,
  #     "uuid": "372e03aa-59c1-11e4-8b9e-3c15c2d24fd8",
  #     "name": "work name",
  #     "description": "description do  ... ",
  #     "model": {
  #       "key": iphone_6_cases,
  #       "name": "iphone 6",
  #     },
  #     "cover_image": {
  #       "thumb": "\/uploads\/work\/cover_image\/1\/thumb_test.jpg",
  #       "normal": "\/uploads\/work\/cover_image\/1\/test.jpg"
  #     },
  #     "policy": "public",
  #     "finished": false,
  #     "layers": [],
  #     "user": {
  #       "id": 1,
  #       "email": "user1@commandp.me",
  #       "avatar": {
  #         "thumb": "\/assets\/editor\/default_avatar.png",
  #         "normal": "\/assets\/editor\/default_avatar.png"
  #       },
  #       "username": null,
  #       "role": "normal"
  #     }
  #   }
  #
  # @param request work_uuid [String] work uuid
  #
  # @return [JSON] status 200

  def show
    @work = Work.is_public.find_by!(uuid: params[:uuid])
    render json: @work, serializer: FinishWorkSerializer, root: false
    fresh_when(etag: @work, last_modified: @work.updated_at)
  end
end
