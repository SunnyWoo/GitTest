module Concerns::HasLegacyEvents
  def change_price_22_9
    # 事件：將所有商品價格調為 22.9
    # 時間：20160229 0000
    price_tier = PriceTier.where("prices->>'CNY' = ?", '22.9').first
    return true unless price_tier

    event = ScheduledEvent.find_by(name: 'change_price_22_9')
    return true unless event

    # 更新 ProductModel customized_special_price_tier_id
    # ProductCategory#Sticker 不用動價格
    sticker_id = ProductCategory.find_by(key: 'sticker').id
    pms = ProductModel.available.where.not(category_id: sticker_id)
    original_pm_special_prices = pms.map { |pm| [pm.id, pm.customized_special_price_tier_id] } # 備份用
    pms.update_all(customized_special_price_tier_id: price_tier.id)

    # 更新 Work.is_public price_tier_id
    # 要排除 動漫英雄系列
    designer_ids = Designer.where('display_name like ?', '动漫英雄%').pluck(:id)
    works = Work.is_public.where(model_id: pms.pluck(:id)).where.not('user_type = ? AND user_id IN (?)', 'Designer', designer_ids)
    original_work_prices = works.map { |work| [work.id, work.price_tier_id] }
    works.update_all(price_tier_id: price_tier.id)

    # 更新 StandardizedWork.is_public
    std_works = StandardizedWork.is_public.where(model_id: pms.pluck(:id)).where.not('user_type = ? AND user_id IN (?)', 'Designer', designer_ids)
    original_std_work_prices = std_works.map { |work| [work.id, work.price_tier_id] }
    std_works.update_all(price_tier_id: price_tier.id)

    # 備份
    event.extra_info = {
      original_pm_special_prices: original_pm_special_prices,
      original_work_prices: original_work_prices,
      original_std_work_prices: original_std_work_prices
    }
    event.save
  end

  def backup_price_22_9
    # 活動: 將價格從 change_price_22_9 調回來
    # 時間: 20160301 0000
    event = ScheduledEvent.find_by(name: 'change_price_22_9')
    return true unless event
    event.extra_info['original_pm_special_prices'].each do |id, price_tier_id|
      pm = ProductModel.find id
      pm.update_columns(customized_special_price_tier_id: price_tier_id)
    end
    event.extra_info['original_work_prices'].each do |id, price_tier_id|
      work = Work.find id
      work.update_columns(price_tier_id: price_tier_id)
    end
    event.extra_info['original_std_work_prices'].each do |id, price_tier_id|
      std_work = StandardizedWork.find id
      std_work.update_columns(price_tier_id: price_tier_id)
    end
  end

  def change_price_4_19
    event = ScheduledEvent.find_by(name: 'change_price_4_19')
    return true unless event

    original_pm_special_prices = {}
    original_work_prices = {}
    original_std_work_prices = {}

    by_category = {
      'case' => 21.0,
      'glass_case' => 21.0,
      'glass_case_tpu' => 21.0,
      'matte_case' => 21.0
    }

    by_model = {
      /2G/ => 21.0,
      /16G/ => 25.0,
      /2500/ => 25.0,
      /5000/ => 38.0
    }

    products = ProductModel.joins(:category)

    ActiveRecord::Base.transaction do
      by_category.each do |key, cny|
        products.where('product_categories.key = ?', key).each do |product|
          price_tier_id = PriceTier.where("prices->>'CNY' = ?", cny.to_s).first.id

          original_pm_special_prices[product.id] = product.customized_special_price_tier_id
          product.works.is_public.each { |w| original_work_prices[w.id] = w.price_tier_id }
          product.standardized_works.is_public.each { |s| original_std_work_prices[s.id] = s.price_tier_id }

          product.update_attributes(customized_special_price_tier_id: price_tier_id)
          product.works.is_public.update_all(price_tier_id: price_tier_id)
          product.standardized_works.is_public.update_all(price_tier_id: price_tier_id)
        end
      end

      products = products.to_a

      by_model.each do |reg, cny|
        products.select { |p| p.key =~ reg }.each do |product|
          price_tier_id = PriceTier.where("prices->>'CNY' = ?", cny.to_s).first.id

          original_pm_special_prices[product.id] = product.customized_special_price_tier_id
          product.works.is_public.each { |w| original_work_prices[w.id] = w.price_tier_id }
          product.standardized_works.is_public.each { |s| original_std_work_prices[s.id] = s.price_tier_id }

          product.update(customized_special_price_tier_id: price_tier_id)
          product.works.is_public.update_all(price_tier_id: price_tier_id)
          product.standardized_works.is_public.update_all(price_tier_id: price_tier_id)
        end
      end

      event.extra_info = {
        original_pm_special_prices: original_pm_special_prices,
        original_work_prices: original_work_prices,
        original_std_work_prices: original_std_work_prices
      }
      event.save
    end
  end

  def backup_price_4_19
    event = ScheduledEvent.find_by(name: 'change_price_4_19')
    return true unless event

    event.extra_info['original_pm_special_prices'].each do |id, price_tier_id|
      pm = ProductModel.find id
      pm.update_columns(customized_special_price_tier_id: price_tier_id)
    end
    event.extra_info['original_work_prices'].each do |id, price_tier_id|
      work = Work.find id
      work.update_columns(price_tier_id: price_tier_id)
    end
    event.extra_info['original_std_work_prices'].each do |id, price_tier_id|
      std_work = StandardizedWork.find id
      std_work.update_columns(price_tier_id: price_tier_id)
    end
  end

  def change_price_4_20
    event = ScheduledEvent.find_by(name: 'change_price_4_20')
    return true unless event

    original_pm_special_prices = {}
    original_work_prices = {}
    original_std_work_prices = {}

    by_category = {
      'mug' => 29.0
    }

    by_model = {
      '15x15cm_canvas_cn' => 9.0,
      '30x30cm_canvas_cn' => 29.0,
      '45x30cm_canvas_cn' => 39.0,
      'wdpillow_35x35cm_psf' => 59.0,
      'wdpillow_35x35cm_pile' => 59.0,
      'wdpillow_45x45cm_psf' => 79.0,
      'wdpillow_45x45cm_pile' => 79.0
    }

    products = ProductModel.joins(:category)

    ActiveRecord::Base.transaction do
      by_category.each do |key, cny|
        products.where('product_categories.key = ?', key).each do |product|
          price_tier_id = PriceTier.where("prices->>'CNY' = ?", cny.to_s).first.id

          original_pm_special_prices[product.id] = product.customized_special_price_tier_id
          product.works.is_public.each { |w| original_work_prices[w.id] = w.price_tier_id }
          product.standardized_works.is_public.each { |s| original_std_work_prices[s.id] = s.price_tier_id }

          product.update_attributes(customized_special_price_tier_id: price_tier_id)
          product.works.is_public.update_all(price_tier_id: price_tier_id)
          product.standardized_works.is_public.update_all(price_tier_id: price_tier_id)
        end
      end

      products = products.to_a

      by_model.each do |k, cny|
        products.select { |p| p.key == k }.each do |product|
          price_tier_id = PriceTier.where("prices->>'CNY' = ?", cny.to_s).first.id

          original_pm_special_prices[product.id] = product.customized_special_price_tier_id
          product.works.is_public.each { |w| original_work_prices[w.id] = w.price_tier_id }
          product.standardized_works.is_public.each { |s| original_std_work_prices[s.id] = s.price_tier_id }

          product.update(customized_special_price_tier_id: price_tier_id)
          product.works.is_public.update_all(price_tier_id: price_tier_id)
          product.standardized_works.is_public.update_all(price_tier_id: price_tier_id)
        end
      end

      event.extra_info = {
        original_pm_special_prices: original_pm_special_prices,
        original_work_prices: original_work_prices,
        original_std_work_prices: original_std_work_prices
      }
      event.save
    end
  end

  def backup_price_4_25
    event = ScheduledEvent.find_by(name: 'change_price_4_20')
    return true unless event

    event.extra_info['original_pm_special_prices'].each do |id, price_tier_id|
      pm = ProductModel.find id
      pm.update_columns(customized_special_price_tier_id: price_tier_id)
    end
    event.extra_info['original_work_prices'].each do |id, price_tier_id|
      work = Work.find id
      work.update_columns(price_tier_id: price_tier_id)
    end
    event.extra_info['original_std_work_prices'].each do |id, price_tier_id|
      std_work = StandardizedWork.find id
      std_work.update_columns(price_tier_id: price_tier_id)
    end
  end
end
