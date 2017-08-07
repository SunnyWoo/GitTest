class Print::RoleGroupsController < PrintController
  def index
    authorize FactoryRoleGroup, :index?
    @role_groups = FactoryRoleGroup.all

    @activities = Logcraft::Activity.where(trackable_type: 'RoleGroup')
                                    .where(trackable_id: @role_groups.map(&:id))
                                    .ordered.channel('print')
                                    .where(key: %w(update create)).limit(30)
  end

  def new
    authorize FactoryRoleGroup, :create?
    @role_group = FactoryRoleGroup.new
  end

  def create
    authorize FactoryRoleGroup, :create?
    @role_group = FactoryRoleGroup.new(role_group_params)
    @role_group.type = 'FactoryRoleGroup'
    if @role_group.save
      create_activity(:create)
      redirect_to print_role_groups_path
    else
      render :new
    end
  end

  def edit
    authorize FactoryRoleGroup, :update?
    @role_group = FactoryRoleGroup.find(params[:id])
  end

  def update
    authorize FactoryRoleGroup, :update?
    @role_group = FactoryRoleGroup.find(params[:id])
    old_role_names = @role_group.roles.map(&:name)
    if @role_group.update(role_group_params)
      create_activity(:update, old_role_names)
      redirect_to print_role_groups_path
    else
      render :edit
    end
  end

  private

  def role_group_params
    params.require(:factory_role_group).permit!
  end

  def create_activity(key, old_role_names = nil)
    @role_group.reload
    log_with_print_channel(@role_group)
    changeset = @role_group.versions.present? ? @role_group.versions.last.changeset : {}
    changeset['roles'] = [old_role_names, @role_group.roles.map(&:name)]
    @role_group.create_activity(key, changeset: changeset)
  end
end
