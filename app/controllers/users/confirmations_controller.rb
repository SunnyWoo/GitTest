class Users::ConfirmationsController < Devise::ConfirmationsController
  before_action :set_device_type

  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      if browser.mobile?
        render 'send', layout: 'campaign'
      else
        respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
      end
    else
      respond_with(resource)
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?
    if resource.errors.empty?
      if browser.mobile?
        render 'success', layout: 'campaign'
      else
        # 认证成功自动登录
        sign_in resource
        set_flash_message(:notice, :confirmed) if is_flashing_format?
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
      end
    else
      if browser.mobile?
        if resource.persisted? && !(resource.send :confirmation_period_valid?)
          render 'expire', layout: 'campaign'
        else
          render 'fail', layout: 'campaign'
        end
      else
        respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
      end
    end
  end

  def set_device_type
    request.variant = browser.mobile? ? :phone : :web
  end
end
