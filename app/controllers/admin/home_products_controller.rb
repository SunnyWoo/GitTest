class Admin::HomeProductsController < AdminController
  def index
    displayed_in_home_page_count = 29
    @works = HomeProducts.scope
    (displayed_in_home_page_count - @works.size).times { @works << nil }
    @works = @works[0...displayed_in_home_page_count]
  end

  def update
    HomeProducts.ids = params[:ids].uniq
    flash[:notice] = '已更新列表'
    redirect_to admin_home_products_path
  end

  def work_names
    q = { name_cont: params[:q],
          work_type_eq: 'is_public' }
    search = Work.ransack(q)
    @works = search.result
    render 'admin/home_products/work_names'
  end
end
