class Admin::FactoryMembersController < AdminController
  before_action :load_factory_options, only: %w(new edit)

  def index
    @factory_members = FactoryMember.includes(:factory).page(params[:page])
  end

  def new
    @factory_member = FactoryMember.new
  end

  def create
    @factory_member = FactoryMember.new(factory_member_params)
    if @factory_member.save
      redirect_to admin_factory_members_path
    else
      load_factory_options
      render :new
    end
  end

  def edit
    @factory_member = FactoryMember.find(params[:id])
  end

  def update
    @factory_member = FactoryMember.find(params[:id])
    if @factory_member.update(factory_member_params)
      redirect_to admin_factory_members_path
    else
      load_factory_options
      render :edit
    end
  end

  def destroy
    redirect_to :back, notice: 'Not implement yet'
  end

  private

  def factory_member_params
    params.require(:factory_member).permit(
      :username, :email, :password,
      :password_confirmation,
      :factory_id
    )
  end

  def load_factory_options
    @factory_options = Factory.all.map { |f| [f.name, f.id] }
  end
end
