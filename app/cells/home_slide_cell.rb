class HomeSlideCell < Cell::Rails
  def home(args = {})
    results = HomeSlide.enabled.where(set: args[:set]).order('id DESC')
    if results.count > 0
      @home_slides = results
      render
    else
      render nothing: true
    end
  end
end
