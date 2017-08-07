# for  web-team 測試 未公開
class Api::V1::TestController < ApiController
  def upload
    user = User.new_guest
    user.update_attributes(test_params)
    render json: {status: 'ok'}
    user.delete
  end

  # 取得 FB Test User, 會排程在 2小時候 自動刪除
  #
  # GET /api/test/fb_test_user
  #     {
  #       "uid": "100009339527877",
  #       "access_token": "CAAIQA1h4nZBcBANwYX4gU2cjiN5QceSPajbjWHiX4BLsEaVj9vSU1LumXW7jNQgic2l4NLCr87v5Imk8ES4FSbiaYGhF2barp6JZBVa8CuSXQEWGDxTOLJw0b6hfsj1fSZBX0eOxeIHJ2gYA7UEhCWa73ZCqV9auYzxgqM4jevoYQOYw7FKpQd8DEhVpm0pqZAHtfGQIQjAZDZD",
  #       "email": "guwxsbt_changwitz_1429158462@tfbnw.net"
  #     }
  #
  # @return JSON
  def fb_test_user
    begin
      test_user = create_test_user.create(true, 'offline_access,read_stream')
      DeleteFbTestusrWorker.perform_in(2.hour, test_user['id'])
      res = { uid: test_user['id'],
              access_token: test_user['access_token'],
              email: test_user['email']
            }
    rescue => e
      res = e
    end
    render json: res
  end

  # 刪除 FB Test User
  #
  # DELETE /api/test/delete_fb_test_user?uid=12345678
  #     {
  #       "status": true
  #     }
  #
  # @return JSON
  def delete_fb_test_user
    begin
      res = create_test_user.delete(params[:uid])
    rescue => e
      res = e
    end
    render json: { status: res }
  end

  private

  def test_params
    params.permit([:avatar])
  end

  def create_test_user
    Koala::Facebook::TestUsers.new( app_id: Settings.Facebook_app_id,
                                    secret: Settings.Facebook_secret)
  end
end