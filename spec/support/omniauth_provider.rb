module OmniauthProvider
  def set_facebook_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
      provider: 'facebook',
      uid: '1234567',
      info: {
        email: 'dev@commandp.com',
        name: 'facebook commandp',
        image: 'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xat1/v/t1.0-1/p50x50/12033127_1489988527992913_7732212801036515865_n.jpg?oh=b49519f5cbaf32835cdd285384856ddd&oe=5662ECF3&__gda__=1453149407_4a73059ab73447a422df70f6c7960ed0',
        location: 'Taipei, Taiwan'
      },
      credentials: {
        token: 'ABCDEF', # OAuth 2.0 access_token, which you may wish to store
        expires_at: 1_321_747_205 # when the access token expires (it always will)
      },
      extra: {
        raw_info: {
          gender: 'male'
        }
      }
    )
    stub_request(:get, 'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xat1/v/t1.0-1/p50x50/12033127_1489988527992913_7732212801036515865_n.jpg?oh=b49519f5cbaf32835cdd285384856ddd&oe=5662ECF3&__gda__=1453149407_4a73059ab73447a422df70f6c7960ed0')
  end

  def set_twitter_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
      provider: 'twitter',
      uid: '123456',
      info: {
        name: 'twitter commandp',
        location: 'Makkah Al Mukarramah, Makkah, Saudi Arabia',
        image: 'https://pbs.twimg.com/profile_images/378800000765628425/1bd9c65300f84da25f31991264b49907_400x400.jpeg'
      },
      credentials: {
        token: 'a1b2c3d4...', # The OAuth 2.0 access token
        secret: '12345678'
      },
      extra: {
        access_token: '', # An OAuth::AccessToken object
        raw_info: {
          name: 'twitter commandp',
          location: 'Makkah Al Mukarramah, Makkah, Saudi Arabia'
        }
      }
    )
    stub_request(:get, 'https://pbs.twimg.com/profile_images/378800000765628425/1bd9c65300f84da25f31991264b49907_400x400.jpeg')
  end

  def set_weibo_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:weibo] = OmniAuth::AuthHash.new(
      provider: 'weibo',
      uid: '1234567890',
      info: {
        name: 'weibo commandp',
        location: '浙江 杭州',
        image: 'http://tp4.sinaimg.cn/1640099215/50/1287016234/1',
        description: 'weibo開放平台申請很麻煩'
      },
      credentials: {
        token: '2.00JjgzmBd7F...', # OAuth 2.0 access_token, which you may wish to store
        expires_at: 1_331_780_640 # when the access token expires (if it expires)
      }
    )
    stub_request(:get, 'http://tp4.sinaimg.cn/1640099215/50/1287016234/1')
  end

  def set_google_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '123456789',
      info: {
        name: 'google commandp',
        email: 'dev@commandp.com',
        image: 'http://vishengsu.b0.upaiyun.com//uploads/2013/02/1264.jpg'
      },
      credentials: {
        token: 'token',
        expires_at: 1_354_920_555
      },
      extra: {
        raw_info: {
          gender: 'male'
        }
      }
    )
    stub_request(:get, 'http://vishengsu.b0.upaiyun.com//uploads/2013/02/1264.jpg')
  end

  def set_not_enough_info_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '123456789',
      info: {
        email: 'dev@commandp.com',
        image: 'http://vishengsu.b0.upaiyun.com//uploads/2013/02/1264.jpg'
      }
    )
    stub_request(:get, 'http://vishengsu.b0.upaiyun.com//uploads/2013/02/1264.jpg')
  end

  def set_qq_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:qq] = OmniAuth::AuthHash.new(
      provider: 'qq',
      uid: '123123',
      info: {
        name: 'qq commandp',
        image: 'http://tp4.sinaimg.cn/1640099215/50/1287016234/1',
        description: 'qq'
      },
      credentials: {
        token: 'qweqwe', # OAuth 2.0 access_token, which you may wish to store
        expires_at: 1_354_920_555 # when the access token expires (if it expires)
      }
    )
    stub_request(:get, 'http://tp4.sinaimg.cn/1640099215/50/1287016234/1')
  end

  def set_wechat_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:wechat] = OmniAuth::AuthHash.new(
      provider: 'wechat',
      uid: 'wechat123',
      info: {
        name: 'wechat commandp',
        image: 'http://tp4.sinaimg.cn/1640099215/50/1287016234/1',
        description: 'wechat'
      },
      credentials: {
        token: 'wechattoken',
        expires_at: 1_354_920_555
      }
    )
    stub_request(:get, 'http://tp4.sinaimg.cn/1640099215/50/1287016234/1')
  end
end
