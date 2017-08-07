class Print::RolesController < PrintController
  def edit
    authorize FactoryRoleGroup, :update?
    @role = Role.find(params[:id])
  end

  def update
    authorize FactoryRoleGroup, :update?
    @role = Role.find(params[:id])
    if @role.update(role_params)
      redirect_to edit_print_role_path(@role), notice: '權限更新成功'
    else
      render :edit
    end
  end

  private

  def role_params
    role_params = params.require(:role).permit(:name, permissions: [])
    role_params[:permissions] = build_permissions(role_params[:permissions] || [])
    role_params
  end

  def build_permissions(permissions)
    parse_permissions(permissions).collect do |permission|
      if @role.nil?
        Permission.new(permission)
      else
        @role.permissions.find_or_initialize_by(permission)
      end
    end
  end

  def parse_permissions(permissions)
    permissions.collect do |permission|
      resource, action = permission.split('#', 2)
      { action: action, resource: resource }
    end
  end
end
