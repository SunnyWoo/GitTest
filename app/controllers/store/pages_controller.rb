class Store::PagesController < Store::FrontendController
  def not_found
    render file: 'public/designer_store/404.html', status: :not_found, layout: false
  end
end
