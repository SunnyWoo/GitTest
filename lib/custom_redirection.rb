class CustomRedirection < Devise::FailureApp
  def redirect_url
    if params[:admin].present?
      Admin.find_by(email: params[:admin][:email]).try do |admin|
        user_agent = UserAgent.parse(request.user_agent)
        admin.logcraft_user = admin
        admin.create_activity(:login_fail, ip: request.remote_ip,
                                           channel: 'web',
                                           os: user_agent.os,
                                           browser: user_agent.browser)
      end
    end
    root_path
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
