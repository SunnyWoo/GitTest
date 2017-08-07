class Admin::FeaturesController < AdminController
  def index
    @features = FeatureFlag::Feature.features.map { |name| feature(name) }
  end

  def enable
    feature(params[:id]).send("enable_for_#{params[:for]}!")
    render nothing: true
  end

  def disable
    feature(params[:id]).send("disable_for_#{params[:for]}!")
    render nothing: true
  end
end
