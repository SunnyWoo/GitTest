class Admin::EmailsController < Admin::ResourcesController
  def index
  end

  def sending
    params['mailers'].each do|mailer|
      tmp = mailer.first.split('.')
      obj = Object.const_get "Fake::#{tmp.first.classify}"
      obj.delay.send(tmp.last, params['email'], params['locale'])
    end
    flash[:notice] = '已經寄出測試 Email.'
    redirect_to action: :index
  end
end
