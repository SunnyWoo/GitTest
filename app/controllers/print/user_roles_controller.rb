class Print::UserRolesController < PrintController
  def index
    authorize FactoryMember, :index?
    @factory_members = current_factory.factory_members

    @activities = Logcraft::Activity.where(trackable_type: 'FactoryMember')
                                    .ordered.channel('print')
                                    .where(key: %w(update create)).limit(30)
  end

  def new
    authorize FactoryMember, :update?
    @factory_member = current_factory.factory_members.new
  end

  def create
    authorize FactoryMember, :update?
    @factory_member = current_factory.factory_members.new(factory_member_params)
    if @factory_member.save
      create_activity
      redirect_to print_user_roles_path
    else
      render :new
    end
  end

  def edit
    authorize FactoryMember, :update?
    @factory_member = current_factory.factory_members.find(params[:id])
  end

  def update
    authorize FactoryMember, :update?
    @factory_member = current_factory.factory_members.find(params[:id])
    form = Print::FactoryMemberForm.new(controller: self, factory_member: @factory_member)
    form.attributes = factory_member_params
    if form.save
      redirect_to print_user_roles_path
    else
      render :edit
    end
  end

  private

  def factory_member_params
    params.require(:factory_member).permit!.tap do |param|
      %i(password password_confirmation).each { |attr| param.delete(attr) } if param[:password].blank?
      param[:enabled] = param[:enabled].to_b
    end
  end

  def create_activity
    log_with_print_channel(@factory_member)
    @factory_member.create_activity(:create, changeset: @factory_member.versions.first.changeset)
  end
end
