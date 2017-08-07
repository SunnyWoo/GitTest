class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :require_no_authentication, if: -> { current_user.try(:guest?) }
  before_action :set_device_type, only: %w(edit update)

  def edit
    super
    render layout: 'campaign' if browser.mobile?
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      if browser.mobile?
        render 'success', layout: 'campaign'
      else
        resource.unlock_access! if unlockable?(resource)
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message(:notice, flash_message) if is_flashing_format?
        sign_in(resource_name, resource)
        redirect_to root_path
      end
    else
      render :edit, layout: 'campaign' if browser.mobile?
    end
  end

  protected

  def set_device_type
    request.variant = browser.mobile? ? :phone : :web
  end
end
