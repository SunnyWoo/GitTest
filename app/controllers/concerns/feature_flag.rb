module FeatureFlag
  extend ActiveSupport::Concern

  included do
    helper_method :feature
  end

  def feature(name, &block)
    @features ||= {}
    feature = @features[name] ||= Feature.new(name, self)

    if block_given?
      feature.determine(&block)
    else
      feature
    end
  end

  module ClassMethods
    def feature_action(name, actions: [])
      before_action only: actions do
        unless feature(name).enable_for_current_session?
          begin
            redirect_to :back
          rescue ActionController::RedirectBackError
            redirect_to root_path
          end
        end
      end
    end
  end
end
