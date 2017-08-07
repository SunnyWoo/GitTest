module AuthRequestHelper
  #
  # pass the @env along with your request, eg:
  #
  # GET '/labels', {}, @env
  #
  def http_login
    @env ||= {}
    user = 'commandp'
    pw = 'commandp'
    @env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pw)
  end

  def feature_http_login
    user = 'commandp'
    password = 'commandp'
    encoded_login = ["#{user}:#{password}"].pack('m*')
    page.driver.header 'Authorization', "Basic #{encoded_login}"
  end

  def setup_admin
    create(:fee, name: '運費')
    create(:product_model)
  end

  def login_admin
    admin = create(:admin)
    login_as(admin, scope: :admin)
    admin
  end

  def login_factory_member
    factory = create(:product_model).factory
    factory_member = create(:factory_member, factory: factory)
    login_as(factory_member, scope: :factory_member)
    factory_member
  end
end
