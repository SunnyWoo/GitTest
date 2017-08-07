module FeatureFlagHelper
  def enable_feature!(name)
    feature = FeatureFlag::Feature.new(name, nil)
    feature.enable_for_admin!
    feature.enable_for_user!
  end
end
