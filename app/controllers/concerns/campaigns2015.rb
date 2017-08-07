module Campaigns2015
  def duncan
    designer = Designer.find_by(username: 'duncandesign')
    if designer
      @works = designer.works.with_available_product.featured
    else
      @works = Work.with_available_product.public_and_recent(1.month).limit(27)
    end

    set_meta_tags title: '我印｜獨家發售 Duncan 設計款聯名 iPhone 手機殼！',
                  description: '我印了，那你呢？超人氣插畫家 Duncan X commandp 要聯手攻佔你的 iPhone！6 款獨家設計手機殼，讓你跟著 Duncan 印起來！',
                  og: {
                    title: '我印｜獨家發售 Duncan 設計款聯名 iPhone 手機殼！',
                    description: '我印了，那你呢？超人氣插畫家 Duncan X commandp 要聯手攻佔你的 iPhone！6 款獨家設計手機殼，讓你跟著 Duncan 印起來！',
                    image: view_context.asset_url('campaign/fb_duncan_share_image.jpg')
                  }
    render :duncan
  end

  def bgmen
    set_meta_tags title: '我印 X BG MEN 搞笑出擊第二波！全面限時特惠再加贈全新 LINE 動態貼圖！',
                  description: '印出你的 BG STYLE！BG MEN 搞笑商品初登場，我印獨家首賣加贈 LINE 動態貼圖！！',
                  og: {
                    title: '我印 X BG MEN 搞笑出擊第二波！全面限時特惠再加贈全新 LINE 動態貼圖！',
                    description: '印出你的 BG STYLE！BG MEN 搞笑商品初登場，我印獨家首賣加贈 LINE 動態貼圖！！',
                    image: view_context.asset_url('campaign/bgmen/bgman_fb_share.jpg')
                  }

    @designer = Designer.find_by!(username: 'bgmen')
    @works = @designer.works.with_available_product

    if browser.mobile?
      process_phone_ver_data
      render :bgmen, layout: 'campaign_v2'
    else
      process_pc_ver_data
      render :bgmen
    end
  end

  def bounce
    set_meta_tags title: '我印 X 塗鴉藝術家 BOUNCE，讓藝術無所不在！',
                  description: '街頭潮流塗鴉藝術家 BOUNCE，讓你把藝術隨身帶著走！',
                  og: {
                    title: '我印 X 塗鴉藝術家 BOUNCE，讓藝術無所不在！',
                    description: '街頭潮流塗鴉藝術家 BOUNCE，讓你把藝術隨身帶著走！',
                    image: view_context.asset_url('campaign/bounce/bounce_post.jpg')
                  }
    @designer = Designer.find_by!(username: 'bounce')
    @works = @designer.works.with_available_product
    if browser.mobile?
      process_phone_ver_data
      render :bounce, layout: 'campaign_v2'
    else
      process_pc_ver_data
      render :bounce
    end
  end

  def canvas
    set_meta_tags title: '我印，讓無框畫變得更有趣！',
                  description: '無框畫方正四角的造型，不論是小店創業、居家生活、或是街頭潮流藝術，都能創造出全新百搭風格，讓你的世界變得更有趣！',
                  og: {
                    title: '我印，讓無框畫變得更有趣！',
                    description: '無框畫方正四角的造型，不論是小店創業、居家生活、或是街頭潮流藝術，都能創造出全新百搭風格，讓你的世界變得更有趣！',
                    image: view_context.asset_url('campaign/canvas/canvas_fbshare.png')
                  }
    @canvas_model = ProductModel.find_by(key: '30x30cm_canvas')
    @canvas_model2 = ProductModel.find_by(key: '45x30cm_canvas')
    @designer = Designer.find_by!(username: 'urbanlegend')
    @works = @designer.works.with_available_product.featured.where(model_id: @canvas_model.id).limit(3)
    @canvas_30_id = ProductModel.find_by(key: '30x30cm_canvas').id
    @canvas_45_id = ProductModel.find_by(key: '45x30cm_canvas').id
    if browser.mobile?
      render :canvas, layout: 'campaign_v2'
    else
      @works += @designer.works.with_available_product.featured.where(model_id: @canvas_model2.id).limit(3)
      render :canvas
    end
  end

  def bosstwo
    @name = '不死兔'
    @key = 'BOSSTWO'
    @title = '我印 X 和超萌系不死兔一起瘋一夏 FUN 暑假！'
    @desc = '瘋一夏 FUN 暑假！不死兔萌萌 der 少女情懷力拼熱熱 der 夏天！'
    @kv_images = {
      bg: 'campaign/bosstwo/kv_bosstwo_bg.png',
      tc: ['campaign/bosstwo/kv_bosstwo_tc.png'],
      en: ['campaign/bosstwo/kv_bosstwo_en.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/bosstwo/kv_bosstwo_mobile_bg.png',
      tc: ['campaign/bosstwo/kv_bosstwo_mobile_tc.png'],
      en: ['campaign/bosstwo/kv_bosstwo_mobile_en.png'],
      alt: @title
    }
    @about_img = 'campaign/bosstwo/about_bosstwo.jpg'
    @about_wording = '不死兔就是一隻不會死的兔子，
                      最喜歡用搞笑的圖文來分享生活上的瑣事。
                      本身是個愛兔成癡的兔奴，家裡飼養兩隻可愛的小兔子：
                      一隻是全白藍眼的帥氣公兔「噗滋」、
                      另一隻是黑白色道奇可愛母兔「噗妮」，
                      可愛的模樣深受粉絲們喜愛！
                      不死兔還有一個非常抖 M 的男友「勝學長」。
                      大家都喜歡看學長被欺負，
                      另類的兩性愛情圖文也深受粉絲們的共鳴與喜愛！'
    @artworks = [*1..4].map { |i| "campaign/bosstwo/artwork_#{i}.jpg" }
    # 因為與just_in_cast共用layout，所以也需要該變數
    @artworks_descriptions = []
    @artworks_class = 'grid_3 camp_artworks'

    @share_img = 'campaign/bosstwo/cp_bosstwo_100_wt.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }

    @designer = Designer.find_by!(username: 'bosstwo')
    @works = @designer.works.with_available_product

    if browser.mobile?
      process_phone_ver_data
      render layout: 'campaign_v2'
    else
      process_pc_ver_data
    end
  end

  def happysummer
    @name = 'HAPPY SUMMER TIME'
    @key = 'HAPPYSUMMER'
    @title = '創造屬於自己的夏天'
    @desc = '快樂一夏，自己的夏天自己印！感受繽紛夏日，將夏天背在身上、拿在手上、貼在紙上，印出獨一無二的客製化創作！'
    @kv_images = {
      bg: 'campaign/happysummer/summertime_bg.png',
      tc: ['campaign/happysummer/summertime_tw.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/happysummer/summertime_mobile_bg.png',
      tc: ['campaign/happysummer/summertime_mobile_tw.png'],
      alt: @title
    }

    @share_img = 'campaign/happysummer/post_summertime.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }

    @materials = %w(palm_tree pineapple navy summertime wave ice_cream oceanlife beach surffing_holiday)

    @designer = Designer.find_by!(username: 'billysommer')
    @works = @designer.works.with_available_product

    @work_models = ProductModel.where(id: @works.map(&:model_id).uniq)
    @work_categories = {}
    @work_models.each do |model|
      @work_categories[model.category_id] ||= { category: model.category, models: [] }
      @work_categories[model.category_id][:models] << model
    end
    @work_categories = @work_categories.sort_by { |_k, v| v[:models].size }.reverse.to_h

    @default_model = ProductModel.find_by(key: 'iphone_6_cases')
    @default_category = @default_model.category

    if browser.mobile?
      # mobile 排除 clock, canvas
      ProductCategory.where(key: %w(clock canvas)).map(&:id).each do |category_id|
        @work_categories.try { |c| c.delete(category_id) }
      end
      process_phone_ver_data
      render :happysummer, layout: 'campaign_v2'
    else
      if params[:m] && params[:m] != 'all-cases'
        @model = ProductModel.wildcard_or_find_by(params[:m])
        @works = @works.where(model_id:  @model.id)
      else
        @model = ProductModel.wildcard
      end
      @works = @works.page(params[:page]).per_page(30)

      render :happysummer
    end
  end

  def happy88
    @key = 'HAPPY88'
    @name = "HAPPY FATHER'S DAY"
    @title = '印出專屬你與爸爸的快樂時光'
    @desc = '你印的不是商品，是你和爸爸共度的快樂時光。今年的父親節，來製作一個充滿創意與快樂的專屬好禮，感謝爸爸一年來的辛勞吧！'
    @kv_images = {
      bg: 'campaign/happy88/happy88_kv_bg.png',
      tc: ['campaign/happy88/happy88_kv.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/happy88/happy88_mobile_kv_bg.png',
      tc: ['campaign/happy88/happy88_mobile_kv.png'],
      alt: @title
    }

    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url('campaign/happy88/happy88_post.jpg')
                  }

    @materials = %w(awesome_dad be_a_best_dad best_dad_ever_blue best_dad_ever_brown captain_dad happy_fathers_day i_love_my_dad super_dad)

    @designer = Designer.find_by!(username: 'opapa')
    @works = @designer.works.with_available_product

    @work_models = ProductModel.where(id: @works.map(&:model_id).uniq)
    @work_categories = {}
    @work_models.each do |model|
      @work_categories[model.category_id] ||= { category: model.category, models: [] }
      @work_categories[model.category_id][:models] << model
    end
    @work_categories = @work_categories.sort_by { |_k, v| v[:models].size }.reverse.to_h

    @default_model = ProductModel.find_by(key: 'iphone_6_cases')
    @default_category = @default_model.category

    if browser.mobile?
      process_phone_ver_data
      render :happy88, layout: 'campaign_v2'
    else
      if params[:m] && params[:m] != 'all-cases'
        @model = ProductModel.wildcard_or_find_by(params[:m])
        @works = @works.where(model_id:  @model.id)
      else
        @model = ProductModel.wildcard
      end
      @works = @works.page(params[:page]).per_page(30)
      render :happy88
    end
  end

  def valentine08
    @key = 'valentine08'
    @name = 'DOUBLE LOVE'
    @title = '七夕情人節限定 DOUBLE LOVE'
    @desc = '愛揪是要黏一起！七夕就是要放閃啊！不然要幹嘛咧？'
    @kv_images = {
      bg: 'campaign/valentine08/kv_vday_bg.png',
      tc: ['campaign/valentine08/kv_vday_tc2.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/valentine08/kv_vday_bg_mobile.png',
      tc: ['campaign/valentine08/kv_vday_tc_mobile.png'],
      alt: @title
    }

    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url('campaign/valentine08/valentines_post.jpg')
                  }

    @materials = ['Couple In Love', 'Date Black', 'Date Red', 'Flower love', 'Lovebird Blue', 'Lovebird Yellow', 'Fall in love', 'Falling In Love',
                  'Forever love', 'Full of Love', 'Only Love', 'Pokelove',
                  'Shining Love', 'Sweet Heart']

    @work_models = ProductModel.ransack(category_key_in: [:case, :mug, :smartcard]).result.available
    @work_categories = {}
    @work_models.each do |model|
      @work_categories[model.category_id] ||= { category: model.category, models: [] }
      @work_categories[model.category_id][:models] << model
    end
    @work_categories = @work_categories.sort_by { |_k, v| v[:models].size }.reverse.to_h

    @default_model = ProductModel.find_by(key: 'iphone_6_cases')
    @default_category = @default_model.category

    if browser.mobile?
      render :valentine08, layout: 'campaign_v2'
    else
      render :valentine08
    end
  end

  def just_in_case
    @name = 'Justin Chou'
    @key = 'Justin Chou'
    @title = '我印 X 有個性不需要時尚 沒個性時尚也無用 – Just In Case iPhone case'
    @desc = '新銳設計師周裕穎用不盲從的時尚態度，與我印聯合出擊，一起成為時尚的反叛軍！'
    @kv_images = {
      bg: 'campaign/just_in_case/kv_just_in_case_bg.png',
      tc: ['campaign/just_in_case/kv_just_in_case_tc.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/just_in_case/kv_just_in_case_mobile_bg.png',
      tc: ['campaign/just_in_case/kv_just_in_case_mobile_tc.png'],
      alt: @title
    }
    @about_img = 'campaign/just_in_case/about.jpg'
    @sign_img = 'campaign/just_in_case/sign.png'
    @about_wording = '設計師周裕穎，2005 年畢業於義大利米蘭 Domus 設計學院。
                      2007 年成立 Just In Case 後就一直致力於創造出一種屬於超現實與沒有時間性的服裝風格。
                      所有的創作皆呈現出獨一無二的手工質感與概念，以滿足那些擁有自己想法的時裝哲學家們。
                      周裕穎為 2014 年臺北時尚新銳設計師大賽 - 金獎得主，
                      2015 年更創立了女裝品牌 DODOBIRD by Just In Case。
                      歌手 A-Lin 到大陸參加我是歌手歌唱節目比賽經常穿著 JIC 的服裝，
                      ELLE 雜誌蕭敬騰封面也是穿著 JIC 的服裝，因為設計風格獨特，是許多明星的御用品牌之一。

                      JIC PROJECT 10 是 Just In Case 10個反叛時尚系列
                      （Fashion Sucks Project） 中的第一個計畫 ：
                      以游擊隊軍裝當藍圖，幾位時裝界反時尚的靈魂人物為導師，
                      進而成立的一個反叛者團體：DFM (Don\'t Follow Me) ，
                      發表的方式與系列的轉換，也將以脫離一般時裝流行體系，
                      期望用游擊隊的精神來痛擊大眾流行文化,，
                      並期望更多的反叛人士一起加入這場反流行聖戰。
                      此次手機殼的設計概念便是以反派時尚系列做為延續。'
    @artworks = [*1..6].map { |i| "campaign/just_in_case/artwork_#{i}.jpg" }
    @artworks_descriptions = [
      '蕭敬騰拍攝 ELLE 雜誌封面 ',
      '第 2 屆大人物慈善攝影展：藍心湄與任賢齊',
      '周杰倫拍攝雜誌宣傳照',
      'A-Lin 參加歌唱節目《我是歌手》',
      '張震出席電影《赤道》 發表會',
      '戴佩妮出席金曲獎紅地毯'
    ]
    @artworks_class = 'grid_2 camp_artworks2'

    @share_img = 'campaign/just_in_case/fb_post.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }

    @designer = Designer.find_by!(username: 'justinchou')
    @works = @designer.works.with_available_product

    if browser.mobile?
      process_phone_ver_data
      render layout: 'campaign_v2'
    else
      process_pc_ver_data
    end
  end

  def masterhands
    @name = '黃星瀚'
    @key = 'MasterHands'
    @title = '我印 X 泰國的流浪日常'
    @desc = '保留住旅遊的愉快回憶，跟著知名VJ星瀚一起把回憶做成商品'
    @kv_images = {
      bg: 'campaign/masterhands/kv_bg.png',
      tc: ['campaign/masterhands/kv_tc.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/masterhands/mobile_kv_bg.png',
      tc: ['campaign/masterhands/mobile_kv_tc.png'],
      alt: @title
    }
    @about_img = 'campaign/masterhands/about.jpg'
    @about_wording = 'MasterHands 高手娛樂 線上雜誌 CEO
                      中廣I-Radio 96.3 I-Play DJ
                      International Yoga Association 200 小時瑜珈老師

                      曾任【音樂人交流協會年度十大專輯.單曲】評審
                     「努力的活，活出自我 ，做就對了！」就是我的座右銘

                      這樣一個五顏六色的國際城市，習慣用相機紀錄生活的我，
                      用著跟別人不一樣的觀點來看這個世界，也許只是在泰國隨手
                      可得的飲料或者一條條會讓你想起恐怖片電影回憶的小巷，
                      在飯店泳池的玩耍~都是記憶的過程~也是屬於我對泰國的回憶。'

    @share_img = 'campaign/masterhands/fb_post.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }

    @designer = Designer.find_by!(username: 'masterhands')
    @works = @designer.works.with_available_product

    if browser.mobile?
      process_phone_ver_data
      render layout: 'campaign_v2'
    else
      process_pc_ver_data
    end
  end

  def thechick
    @name = '大陰盜百貨'
    @key = 'thechick'
    @title = '我印 X 大陰盜百貨 穿越雞搶購季人人都瘋年中慶'
    @desc = '千呼萬喚雞姐來！貴婦、櫃姐、優質文青期盼已久、人人都愛的大陰盜百貨，終於等到瘋狂購物節啦！多種不甘願的聯名商品，等你來搶購！'
    @kv_images = {
      bg: 'campaign/thechick/kv_bg.png',
      tc: ['campaign/thechick/kv_tc.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/thechick/mobile_kv_bg.png',
      tc: ['campaign/thechick/mobile_kv_tc.png'],
      alt: @title
    }
    @about_img = 'campaign/thechick/about.jpg'
    @about_wording = '大陰盜百貨就是一個關於櫃哥櫃姐以及服務業日常的漫畫集，
                      我就是名字很猥褻但是作品一點都不猥褻的陰盜哥。'
    @artworks = [*1..4].map { |i| "campaign/thechick/artwork_thechick_#{i}.jpg" }
    @artworks_descriptions = []
    @artworks_class = 'grid_3 camp_artworks'
    @share_img = 'campaign/thechick/fb_post.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }

    @designer = Designer.find_by!(username: 'thechick')
    @works = @designer.works.with_available_product

    if browser.mobile?
      process_phone_ver_data
      render layout: 'campaign_v2'
    else
      process_pc_ver_data
    end
  end

  def musicrun
    @name = 'MUSIC RUN'
    @key = 'musicrun'
    @title = '我印 X THE MUSIC RUN'
    @desc = '跑出你的音樂節奏 印出你的音樂風格！ 跟我印一起把熱情活力傳給需要幫助的幼苗吧！'
    @kv_images = {
      bg: 'campaign/musicrun/kv_bg.png',
      tc: ['campaign/musicrun/kv_tc.png'],
      en: ['campaign/musicrun/kv_en.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/musicrun/mobile_kv_bg_new.png',
      tc: ['campaign/musicrun/mobile_kv_tc_new.png'],
      en: ['campaign/musicrun/mobile_kv_en_new.png'],
      alt: @title
    }
    @share_img = 'campaign/musicrun/fb_post.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @materials = (1..9).map { |i| "hip_hop_#{i}" }
    @work_models = ProductModel.where(key: %w(iphone_6_cases iphone_6plus_cases iphone_5_cases samsung_note3_cases mugs easycard_smartcards 30x30cm_canvas))
    @work_categories = {}
    @work_models.each do |model|
      @work_categories[model.category_id] ||= { category: model.category, models: [] }
      @work_categories[model.category_id][:models] << model
    end
    @work_categories = @work_categories.sort_by { |_k, v| v[:models].size }.reverse.to_h
    @default_model = ProductModel.find_by(key: 'iphone_6_cases')
    @default_category = @default_model.category
    photo_list = ["_1390819.jpg", "_1390841.jpg", "P1390961.jpg", "_1390838.jpg", "P1390950.jpg", "P1390954.jpg",
                  "P1390969.jpg", "P1390966.jpg", "P1400060.jpg", "_1390842.jpg", "P1390965.jpg", "_1390811.jpg",
                  "P1390931.jpg", "P1400021.jpg", "P1400040.jpg", "_1390829.jpg", "P1390995.jpg", "_1390845.jpg",
                  "P1390918.jpg", "_1390846.jpg", "_1390814.jpg", "P1390885.jpg", "P1400013.jpg", "P1390944.jpg",
                  "P1400053.jpg", "P1400054.jpg", "P1400041.jpg", "P1390907.jpg", "_1390810.jpg", "P1390973.jpg",
                  "P1390972.jpg", "P1390984.jpg", "P1390906.jpg", "P1390910.jpg", "P1390959.jpg", "P1390989.jpg",
                  "P1390986.jpg", "P1390937.jpg", "_1390834.jpg", "_1390821.jpg", "P1390940.jpg", "P1390929.jpg",
                  "P1390926.jpg", "_1390852.jpg", "P1400058.jpg", "_1390806.jpg", "P1400016.jpg", "P1390979.jpg",
                  "P1390953.jpg", "P1390895.jpg", "P1390921.jpg", "P1400062.jpg", "P1390993.jpg", "P1390928.jpg",
                  "P1390914.jpg", "P1400018.jpg", "_1390809.jpg", "P1400003.jpg", "P1390901.jpg", "_1390808.jpg",
                  "P1390900.jpg", "P1390888.jpg", "P1390952.jpg", "P1390935.jpg", "P1400038.jpg", "P1390981.jpg",
                  "P1400063.jpg", "P1390932.jpg", "P1390957.jpg", "P1390905.jpg", "P1390960.jpg", "P1400034.jpg",
                  "P1390947.jpg", "P1390916.jpg", "P1390917.jpg", "P1390936.jpg", "P1390967.jpg", "P1390942.jpg",
                  "_1390843.jpg", "P1400033.jpg", "P1400019.jpg", "P1390923.jpg", "P1390948.jpg", "P1400037.jpg",
                  "P1390990.jpg", "P1400020.jpg", "P1400026.jpg", "P1390902.jpg", "P1390892.jpg", "P1390933.jpg",
                  "P1400029.jpg", "P1390998.jpg", "_1390850.jpg", "P1400023.jpg", "_1390851.jpg", "P1390896.jpg",
                  "P1400009.jpg", "P1390999.jpg", "P1390946.jpg", "P1390924.jpg", "_1390844.jpg", "P1400010.jpg",
                  "_1390832.jpg", "P1390898.jpg", "P1390978.jpg", "P1390968.jpg", "P1390956.jpg", "P1390982.jpg",
                  "_1390817.jpg", "_1390849.jpg", "P1400017.jpg", "P1390988.jpg"]
    @photos = photo_list.paginate(page: params[:photo_page], per_page: 9)
    if browser.mobile?
      render :musicrun, layout: 'campaign_v2'
    else
      render :musicrun
    end
  end

  def daryl
    @name = '白白'
    @key = 'daryl'
    @title = '我印 x line貼圖之星 療癒系白白 '
    @desc = '不管去哪裡就是要黏著你，療癒系白白變身手機殼，隨身帶著走，白白陪你一起過日子，溫暖你的心!'
    @kv_images = {
      bg: 'campaign/daryl/kv_bg.png',
      tc: ['campaign/daryl/kv_tc.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/daryl/mobile_kv_bg.png',
      tc: ['campaign/daryl/mobile_kv_tc.png'],
      alt: @title
    }
    @share_img = 'campaign/daryl/fb_post.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @about_img = 'campaign/daryl/about.jpg'
    @about_wording = 'Daryl Cheung，一個名字經常被寫錯和讀錯的香港人，於香港理工大學平面
                      設計系畢業，其後以設計師和插畫師身份生活著。 喜歡畫畫，喜歡手作，喜歡攝影，
                      喜歡觀察。曾為報章畫插畫，也有跟不同的品牌及商場合作。

                      筆下有一頭陪伴了好一段歲月的熊，期後洐生成現在的白白，幸運地透過
                      LINE Creator Market推出貼圖後得到很多人的喜愛。'

    @designer = Designer.find_by!(username: 'darylhochi')
    @works = @designer.works.with_available_product

    @artworks = (1..6).map { |i| "campaign/daryl/daryl_artwork_#{i}.png" }
    @artworks_descriptions = []
    @artworks_class = 'grid_3 camp_artworks'

    if browser.mobile?
      process_phone_ver_data
      render layout: 'campaign_v2'
    else
      process_pc_ver_data
    end
  end

  def picnic
    @key = 'picnic'
    @name = "LET'S GO PICNIC"
    @title = '擁抱夏天的尾巴，就一起趣野餐吧！'
    @desc = '我們幫你準備好了今年必備的野餐包，就跟著我印趣野餐吧！'
    @kv_images = {
      bg: 'campaign/picnic/kv_bg.png',
      tc: ['campaign/picnic/kv_tc.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/picnic/mobile_kv_bg.png',
      tc: ['campaign/picnic/mobile_kv_tc.png'],
      alt: @title
    }
    @share_img = 'campaign/denka/denka_fb_post.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @materials = (1..6).map { |i| "picnic_materal_#{i}" }
    @work_models = ProductModel.where(key: %w(iphone_6_cases iphone_6plus_cases iphone_5_cases samsung_note3_cases
                                            samsung_s5_cases samsung_s4_cases mugs easycard_smartcards 30x30cm_canvas))
    @work_categories = {}
    @work_models.each do |model|
      @work_categories[model.category_id] ||= { category: model.category, models: [] }
      @work_categories[model.category_id][:models] << model
    end
    @work_categories = @work_categories.sort_by { |_k, v| v[:models].size }.reverse.to_h
    @default_model = ProductModel.find_by(key: 'iphone_6_cases')
    @default_category = @default_model.category
    @designer = Designer.find_by!(username: 'picnic')
    @works = @designer.works.with_available_product
    if browser.mobile?
      process_phone_ver_data
      render :picnic, layout: 'campaign_v2'
    else
      process_pc_ver_data
      render :picnic
    end
  end

  def denka
    @key = 'DenKa'
    @name = 'DenKa'
    @title = '我印 X DenKa'
    @desc = '顛覆你的迪士尼故事，跨界聯名就是要給你不一樣的DenKa'
    @kv_images = [{
      bg: 'campaign/denka/kv_denka_bg.png',
      denka_mode: true,
      left: ['campaign/denka/kv_denka_1.png', 'campaign/denka/kv_denka_2.png', 'campaign/denka/kv_denka_3.png',
        'campaign/denka/kv_denka_7.png', 'campaign/denka/kv_denka_8.png', 'campaign/denka/kv_denka_9.png',
      ],
      tc: 'campaign/denka/kv_denka_cn.png',
      right: ['campaign/denka/kv_denka_4.png', 'campaign/denka/kv_denka_5.png', 'campaign/denka/kv_denka_6.png',
        'campaign/denka/kv_denka_10.png', 'campaign/denka/kv_denka_11.png'
      ],
      alt: @title
    }]
    @kv_mobile_images = [{ bg: 'campaign/denka/mobile/kv_bg1.png',
                           tc: 'campaign/denka/mobile/kv_denka_cn@2x.png',
                           href: '#product',
                           button: true,
                           alt: @title
                         }, {
                           bg: 'campaign/denka/mobile/kv_bg2.png',
                           tc: 'campaign/denka/mobile/kv_denka_cn@2x.png',
                           href: '#product',
                           button: true,
                           alt: @title
                         }, {
                           bg: 'campaign/denka/mobile/kv_bg3.png',
                           tc: 'campaign/denka/mobile/kv_denka_cn@2x.png',
                           href: '#product',
                           button: true,
                           alt: @title
                         }, {
                           bg: 'campaign/denka/mobile/kv_bg4.png',
                           tc: 'campaign/denka/mobile/kv_denka_cn@2x.png',
                           href: '#product',
                           button: true,
                           alt: @title
                         }, {
                           bg: 'campaign/denka/mobile/kv_bg5.png',
                           tc: 'campaign/denka/mobile/kv_denka_cn@2x.png',
                           href: '#product',
                           button: true,
                           alt: @title }]
    @share_img = 'campaign/denka/denka_fb_post2.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @work_models = ProductModel.where(key: %w(iphone_6_cases iphone_6plus_cases iphone_5_cases samsung_note3_cases
                                            samsung_s5_cases samsung_s4_cases mugs easycard_smartcards 30x30cm_canvas))
    @designer = Designer.find_by(username: 'denka') || Designer.last
    @works = @designer.works.with_available_product
    if browser.mobile?
      process_phone_ver_data
      render :denka, layout: 'campaign_v2'
    else
      process_pc_ver_data
      render :denka
    end
  end

  def merryxmas
    @key = 'merryxmas'
    @name = "XMAS 造夢計畫"
    @title = '造夢計畫-和我印一起讓夢想發芽'
    @desc = '我印邀你一起創造做夢的勇氣'
    @kv_images = {
      bg: 'campaign/merryxmas/kv_bg.png',
      tc: ['campaign/merryxmas/kv_tc.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/merryxmas/mobile_kv_bg.png',
      tc: ['campaign/merryxmas/mobile_kv_tc.png'],
      alt: @title
    }
    @share_img = 'campaign/merryxmas/denka_fb_post.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @designer = Designer.find_by!(username: 'dreamon')
    @works = @designer.works.with_available_product
    @merryxmas_fund_price = $redis.get('merryxmas_fund_price') || 379
    photo_list = (1..60).map{|i| "#{i.to_s.rjust(2,'0')}.png"}
    @photos = photo_list.paginate(page: params[:photo_page], per_page: 6)
    if browser.mobile?
      process_phone_ver_data
      render :merryxmas, layout: 'campaign_v2'
    else
      process_pc_ver_data
      render :merryxmas
    end
  end

  def atouchofgreen
    @key = 'atouchofgreen'
    @name = "我印Ｘ一把青"
    @title = '我印Ｘ一把青 我們的歷史.台北的故事'
    @desc = '2015時值抗戰70週年的歷史時代,親臨戰爭的⼈人們逐漸凋零. 我印與你一同穿梭時光,用不同的角度來回顧那個即將逝去的世代'
    @kv_images = {
      bg: 'campaign/atouchofgreen/kv_bg.png',
      tc: ['campaign/atouchofgreen/kv_tc.png'],
      alt: @title
    }
    @kv_mobile_images = {
      bg: 'campaign/atouchofgreen/mobile_kv_bg.png',
      tc: ['campaign/atouchofgreen/mobile_kv_tc.png'],
      alt: @title
    }
    @share_img = 'campaign/atouchofgreen/fb_post.jpg'
    set_meta_tags title: @title,
                  description: @desc,
                  og: {
                    title: @title,
                    description: @desc,
                    image: view_context.asset_url(@share_img)
                  }
    @designer = Designer.find_by!(username: 'retroqixi')

    @works = @designer.works.with_available_product
    if browser.mobile?
      process_phone_ver_data
      render :atouchofgreen, layout: 'campaign_v2'
    else
      process_pc_ver_data
      render :atouchofgreen
    end
  end

  def simple_campaign
    @name = @campaign.name
    @key = @campaign.key
    @title = @campaign.title
    @desc = @campaign.desc
    campaign_images = @campaign.campaign_images
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
    @about_wording = @campaign.about_designer

    @designer = Designer.find_by!(username: @campaign.designer_username)
    @works = @designer.standardized_works.published.with_available_product
    @works = @designer.works.with_available_product if @works.size == 0

    @artworks = campaign_images.where(key: 'artwork')
    @artworks_class = @campaign.artworks_class
    @wordings = @campaign.wordings
    @ig_images = if @wordings.try(:instagram_htag).present?
                   get_ig_images(@wordings.instagram_htag, 8, 'low_resolution')
                 else
                   get_ig_cp_images(8, 'low_resolution')
                 end
    if browser.mobile?
      process_phone_ver_data
      render layout: 'campaign_v2'
    else
      process_pc_ver_data
    end
  end
end
