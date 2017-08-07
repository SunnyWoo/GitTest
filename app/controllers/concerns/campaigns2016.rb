module Campaigns2016
  def nyresolution
    @name = 'nyresolution'
    @key = 'nyresolution'
    @title = '2016. I Wish, I Print.'
    @desc = '還記得2015年對自己許的願嗎？是不是都沒有實現呢？讓我們從2016年開始許下嶄新的新期許, 把它印成生活小物時時提醒～為更好的自己加油打氣吧！'
    @kv_mobile_images = {
      bg: 'campaign/2016/nyresolution/mobile_kv_bg.png',
      tc: ['campaign/2016/nyresolution/mobile_kv_tc.png'],
      alt: @title
    }
    @designer = Designer.find_by!(username: 'newyear2016')
    @works = @designer.works.with_available_product
    @ig_images = get_ig_images('iwishiprint', 8, 'thumbnail')
    @previews = %w(download_betty.jpg download_diary.jpg download_family.jpg download_jean.jpg download_kiwi.jpg
                   download_money.jpg download_sarah.jpg download_smoking.jpg download_tracy.jpg download_traveling.jpg
                   download_vivian.jpg downloads_saier.jpg)

    request.variant = :phone
    process_phone_ver_data
    render :nyresolution, layout: 'campaign_v2'
  end

  def lucky2016
    @key = '2016lucky'
    @name = '我印幫你轉轉運'
    @title = '今年想要有好運氣，我印幫你轉轉運'
    @desc = '讓幸運服的老師幫你找出隱藏版的星星！解答你2016的運勢吧！'
    @kv_images = [{
      bg: 'campaign/2016/2016lucky/images/cp_web_kv_bg_lucky_tw.png',
      tc: 'campaign/2016/2016lucky/images/cp_web_kv_design_lucky_tw.png',
      alt: @title
    }]
    @kv_mobile_images = {
      bg: 'campaign/2016/2016lucky/images/cp_mobile_kv_bg_lucky_tw.png',
      tc: ['campaign/2016/2016lucky/images/cp_mobile_kv_design_lucky_tw.png'],
      alt: @title
    }
    @date_model = {
      'year_range' => (1900..2016).to_a.sort! { |x, y| y <=> x },
      'month_range' => (1..12).to_a,
      'hour_range' => (1..24).to_a
    }
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @designer = Designer.find_by(username: 'luckystar') || Designer.last
    @works = @designer.works.with_available_product
    @work_models = ProductModel.where(id: @works.map(&:model_id).uniq)

    if browser.mobile?
      process_phone_ver_data
      render :lucky2016, layout: 'campaign_v2'
    else
      process_pc_ver_data
      render :lucky2016
    end
  end

  def camera360
    @key = 'camera360'
    @title = 'Camera 360 “拍下为他用心准备的礼物”'
    @kv_mobile_images = {
      bg: 'campaign/2016/camera360/camera360-campaign-bg.jpg',
      tc: ['campaign/2016/camera360/camera360-campaign-kv.png'],
      alt: @title
    }
    @gift = Hash[
      'gift_name' => 'Camera360 挑战活动',
      'gift_desc' => '进入Camera360 图片挑战活动，参与“拍下为TA用心准备的礼物”主题，即有机会获得噗印折扣券。',
      'gift_plean_title' => '兑换流程：',
      'gift_mode' => '1.在APP Store下载“噗印”<br/>
        2.进入主题活动“Camera 360 挑战活动 兑换专区”<br/>
        3.选择商城中任意产品，或者选择“开始印”自己DIY<br/>
        4.将产品加入购物车，并在支付界面输入折扣码，完成支付<br/>
        5.除了得奖用户的超低价折扣码之外，所有参与活动者，只需输入“CAMERA360”,即可立享7折优惠！<br/>
        6.兑换券有效期至：2016年4月30日<br/>',
      'download_ios_image_url' => 'campaign/2016/camera360/img_download_ios@2x.png',
      'download_android_image_url' => 'campaign/2016/camera360/img_download_android@2x.png',
      'download_ios_url' => 'https://itunes.apple.com/cn/app/wo-yin-shou-ji-ke-ba-ni-zhao/id898632563?l=zh&mt=8?footer',
      'download_android_url' => 'https://cp-to-qiniu-prod.b0.upaiyun.com/download/android/commandp-latest.apk'
    ]
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @designer = Designer.find_by(username: 'luckystar') || Designer.last
    @works = @designer.works.with_available_product
    @work_models = ProductModel.where(id: @works.map(&:model_id).uniq)

    request.variant = :phone
    process_phone_ver_data
    render :camera360, layout: 'campaign_v2'
  end

  def mothersday
    @key = 'mothersday'
    apply_simple_campaign_data
    @materials = %w(01 02 03 04 05 06)

    if browser.mobile?
      render :mothersday, layout: 'campaign_v2'
    else
      render :mothersday
    end
  end

  # image_size: thumbnail(150*150) low_resolution(320*320) standard_resolution(640*640)
  def get_ig_images(tag, count = 10, image_size = 'low_resolution')
    images = []
    client_id = '5607761e84f14957963372e68c0409b8'
    ig = HTTParty.get("https://api.instagram.com/v1/tags/#{tag}/media/recent?client_id=#{client_id}&count=#{count}")
    if ig['meta'] && ig['meta']['code'] == 200 && ig['data'].size > 0
      images = ig['data'].map{ |d| d['images'][image_size]['url'] }
    end
    images
  end

  def apply_simple_campaign_data(key = nil)
    original_campaign = Campaign.find_by_key!(key || @key)
    simple_campaign_data original_campaign
  end

  def simple_campaign_data(campaign = nil)
    campaign = @campaign if campaign.blank?
    @name = campaign.name
    @key = campaign.key
    @title = campaign.title
    @desc = campaign.desc
    campaign_images = campaign.campaign_images
    @kv_images = {
      bg: campaign_images.render_image('kv_bg'),
      tc: campaign_images.render_images('kv_tc'),
      alt: @title
    }
    @kv_mobile_images = {
      bg: campaign_images.render_image('m_kv_bg'),
      tc: campaign_images.render_images('m_kv_tc'),
      alt: @title
    }
    @share_img = campaign_images.render_image('fb_share')
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @about_img = campaign_images.render_image('about')
    @sign_img = campaign_images.render_image('sign')
    @about_wording = campaign.about_designer

    @designer = Designer.find_by!(username: campaign.designer_username)
    @works = @designer.standardized_works.published.with_available_product
    @works = @designer.works.with_available_product if @works.size == 0

    @artworks = campaign_images.where(key: 'artwork')
    @artworks_class = campaign.artworks_class
    @wordings = campaign.wordings
    @ig_images = if @wordings.try(:instagram_htag).present?
                   get_ig_images(@wordings.instagram_htag, 8, 'low_resolution')
                 else
                   get_ig_cp_images(8, 'low_resolution')
                 end

    if browser.mobile?
      process_phone_ver_data
    else
      process_pc_ver_data
    end
  end
end
