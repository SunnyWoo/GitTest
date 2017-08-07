class Admin::DesignersController < AdminController
  def index
    @designers = Designer.all.order('created_at DESC')
    @designers = @designers.page(params[:page]) unless params[:page] == 'all'

    respond_to do |f|
      f.html
      f.json { render 'api/v3/designers/index' }
    end
  end

  def new
    @designer = Designer.new
  end

  def create
    @designer = Designer.new(designer_params)
    if @designer.save
      redirect_to admin_designers_path
    else
      render :new
    end
  end

  def edit
    @designer = Designer.find(params[:id])
  end

  def update
    @designer = Designer.find(params[:id])
    if @designer.update(designer_params)
      redirect_to admin_designers_path
    else
      render :edit
    end
  end

  private

  def designer_params
    params.require(:designer).permit(:username, :email, :password,
                                     :password_confirmation, :display_name,
                                     :avatar, :description)
  end
end
