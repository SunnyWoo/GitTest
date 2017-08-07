class BetaController < ApplicationController
  layout 'beta'

  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user)
  end

  helper_method :permitted_params

  def index
  end

  def detail
  end
end
