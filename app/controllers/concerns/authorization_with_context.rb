module AuthorizationWithContext
  extend ActiveSupport::Concern
  include Pundit
  include CurrentCountryCode

  included do
    # ensuring policies are used
    # TODO: 等全站上 pundit 後就可以解鎖這兩行
    # after_action :verify_authorized, except: :index
    # after_action :verify_policy_scoped, only: :index
  end

  def pundit_user
    Context.new(current_user, current_country_code)
  end

  class Context < Struct.new(:user, :country_code)
  end
end
