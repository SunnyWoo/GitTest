class Admin::AdminsController < Admin::ResourcesController
  def after_sign_in_path_for(_resource)
    admin_root_path
  end

  def unlock
    Admin.find(params[:id]).try do |admin|
      admin.unlock_access! if admin.access_locked?
    end
    redirect_to admin_root_path
  end

  def log
    @admin = Admin.find params[:id]
  end
end
