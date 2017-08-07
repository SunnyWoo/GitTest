module SearchSupport
  protected

  def work_class
    Work
  end

  def design_platform
    case os_type.downcase
    when 'ios' then 'ios'
    when 'android' then 'android'
    else
      'website'
    end
  end

  def search_work
    sellable_product_model
    @model = ProductModel.wildcard
    @model = ProductModel.find(params[:model_id]) if params[:model_id].present? && !params[:model_id].match(/,/)
    Timeout.timeout(3) do
      return rescue_search_work if work_class.es_health_check['status'] == 'red'
    end
    params[:design_platform] = design_platform
    @works = work_class.search_for_website_search(params, params[:page], params[:per_page])
  rescue
    rescue_search_work
  end

  def rescue_search_work
    q = { name_cont: params[:query], model_id_in: params[:model_id], category_id_in: params[:category_id] }
    q.merge!(work_user_name_cont: params[:user_name]) if params[:user_name]
    q.merge!(model_key_cont: params[:model_key]) if params[:model_key]
    q.merge!(taggings_tag_collection_tags_collection_name_eq: params[:collection_name]) if params[:collection_name]
    q.merge!(taggings_tag_name_eq: params[:tag_name]) if params[:tag_name]
    @search = Work.with_available_product.is_public.with_sellable_on_product(platform).ransack(q)
    works = @search.result.page(params[:page]).per_page(params[:per_page] || 30)
    @works = Pricing::ItemableDecorator.decorate_collection(works)
  end

  def platform
    if browser.ios?
      'ios'
    elsif browser.android?
      'android'
    else
      'website'
    end
  end

  # 為了判斷 product_model 和對應的 platform 有沒有上架
  # category_id & model_id 可以帶多個 , 隔開
  # product_key 空格 隔開
  # 當 category_id, model_id, product_key 都沒有帶的時候，會撈出該 platfrom 支援的 model_id
  def sellable_product_model
    query = {}
    query[:category_id] = params.delete(:category_id).split(',') if params[:category_id].present?
    query[:id] = params.delete(:model_id).split(',') if params[:model_id].present?
    query[:key] = params.delete(:product_key).split(' ') if params[:product_key].present?
    params[:model_id] = ProductModel.where(query).sellable_on(platform).pluck(:id).join(',')
  end
end
