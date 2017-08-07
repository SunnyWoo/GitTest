class Print::FactoryMembersController < PrintController
  def edit
  end

  def update
    if current_factory_member.update(factory_member_params)
      redirect_to new_factory_member_session_path, alert: '密碼修改成功.'
    else
      render :edit
    end
  end

  private

  def factory_member_params
    params.require(:factory_member).permit(:password, :password_confirmation)
  end
end
