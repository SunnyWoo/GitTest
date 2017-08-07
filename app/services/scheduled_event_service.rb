class ScheduledEventService
  extend Concerns::HasLegacyEvents

  class << self
    # Run in cosonle after deployed:
    # ScheduledEvent.create!(name: 'change_price_0506', scheduled_at: Time.zone.local(2016,5,6,0,0,0))
    def change_price_0506
      event = ScheduledEvent.find_by(name: 'change_price_0506')
      return true unless event

      original_pm_special_prices = {}
      original_work_prices = {}
      original_std_work_prices = {}

      by_category = {
        'case' => 35.0,
        'matte_case' => 35.0,
        'glass_case' => 35.0,
        'glass_case_tpu' => 35.0
      }

      by_model = {
        'usb_white_2G' => 29.0,
        'usb_black_2G' => 29.0,
        'usb_black_16G' => 39.0,
        'usb_white_16G' => 39.0,
        'powerbank_white_2500' => 49.0,
        'powerbank_black_2500' => 49.0,
        'powerbank_white_5000' => 69.0,
        'powerbank_black_5000' => 69.0,
        '15x15cm_canvas_cn' => 15.0,
        '30x30cm_canvas_cn' => 39.0,
        '45x30cm_canvas_cn' => 49.0,
        'shortsleeve_white_l' => 69.0,
        'shortsleeve_white_m' => 69.0,
        'shortsleeve_white_s' => 69.0,
        'shortsleeve_black_l' => 79.0,
        'shortsleeve_black_m' => 79.0,
        'shortsleeve_black_s' => 79.0,
        'shortsleeve_black_xx' => 79.0
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

    # Run in cosonle after deployed:
    # ScheduledEvent.create!(name: 'revert_price_0512', scheduled_at: Time.zone.local(2016,5,12,23,59,59))
    def revert_price_0512
      event = ScheduledEvent.find_by(name: 'change_price_0506')
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

    # Run in cosonle after deployed:
    # ScheduledEvent.create!(name: 'change_price_0513', scheduled_at: Time.zone.local(2016,5,13,0,0,0))
    def change_price_0513
      event = ScheduledEvent.find_by(name: 'change_price_0513')
      return true unless event

      original_pm_special_prices = {}
      original_work_prices = {}
      original_std_work_prices = {}

      by_model = {
        'wdpillow_45x45cm_pile' => 98.0,
        'shortsleeve_white_l' => 90.0,
        'shortsleeve_white_m' => 90.0,
        'shortsleeve_white_s' => 90.0,
        'shortsleeve_black_l' => 98.0,
        'shortsleeve_black_m' => 98.0,
        'shortsleeve_black_s' => 98.0,
        'shortsleeve_black_xx' => 98.0,
        'wdcanvasbag_single' => 98.0,
        'wdcanvasbag_double' => 149.0
      }

      products = ProductModel.all.to_a

      ActiveRecord::Base.transaction do
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

    # Run in cosonle after deployed:
    # ScheduledEvent.create!(name: 'revert_price_0513', scheduled_at: Time.zone.local(2016,5,13,23,59,59))
    def revert_price_0513
      event = ScheduledEvent.find_by(name: 'change_price_0513')
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

    # Run in cosonle after deployed:
    # ScheduledEvent.create!(name: 'change_price_0520', scheduled_at: Time.zone.local(2016,5,20,0,0,0))
    def change_price_0520
      event = ScheduledEvent.find_by(name: 'change_price_0520')
      return true unless event

      original_pm_special_prices = {}
      original_work_prices = {}
      original_std_work_prices = {}

      by_category = {
        'mug' => 33.0
      }

      by_model = {
        'wdpillow_35x35cm_pile' => 66.0, # 双面软毛绒抱枕
        'wdpillow_45x45cm_pile' => 88.0,
        'wdpillow_35x35cm_psf' => 66.0, # 双面桃皮绒抱枕
        'wdpillow_45x45cm_psf' => 77.0,
        'shortsleeve_white_l' => 66.0,
        'shortsleeve_white_m' => 66.0,
        'shortsleeve_white_s' => 66.0,
        'shortsleeve_black_l' => 77.0,
        'shortsleeve_black_m' => 77.0,
        'shortsleeve_black_s' => 77.0,
        'shortsleeve_black_xx' => 77.0,
        'waterpackage_350ml_6pcs' => 33.0,
        'usb_white_2G' => 33.0,
        'usb_black_2G' => 33.0,
        'powerbank_white_2500' => 44.0,
        'powerbank_black_2500' => 44.0,
        '30x30cm_canvas_cn' => 44.0,
        '45x30cm_canvas_cn' => 52.0
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

    # Run in cosonle after deployed:
    # ScheduledEvent.create!(name: 'revert_price_0525', scheduled_at: Time.zone.local(2016,5,25,23,59,59))
    def revert_price_0525
      event = ScheduledEvent.find_by(name: 'change_price_0520')
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

    # Run in cosonle after deployed:
    # ScheduledEvent.create!(name: 'change_price_0526', scheduled_at: Time.zone.local(2016,5,26,0,0,0))
    def change_price_0526
      event = ScheduledEvent.find_by(name: 'change_price_0526')
      return true unless event

      original_pm_special_prices = {}
      original_work_prices = {}
      original_std_work_prices = {}

      by_model = {
        'shortsleeve_white_l' => 89.0,
        'shortsleeve_white_m' => 89.0,
        'shortsleeve_white_s' => 89.0,
        'shortsleeve_black_l' => 99.0,
        'shortsleeve_black_m' => 99.0,
        'shortsleeve_black_s' => 99.0,
        'shortsleeve_black_xx' => 99.0
      }

      products = ProductModel.joins(:category).to_a

      ActiveRecord::Base.transaction do
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

    # Run in cosonle after deployed:
    # ScheduledEvent.create!(name: 'revert_price_0601', scheduled_at: Time.zone.local(2016,6,1,23,59,59))
    def revert_price_0601
      event = ScheduledEvent.find_by(name: 'change_price_0526')
      return true unless event

      event.extra_info['original_pm_special_prices'].each do |id, price_tier_id|
        pm = ProductModel.find id
        pm.update_columns(customized_special_price_tier_id: price_tier_id)
        pm.flush_cached_promotion_prices
      end

      event.extra_info['original_work_prices'].each do |id, price_tier_id|
        work = Work.find id
        work.update_columns(price_tier_id: price_tier_id)
        work.flush_cached_promotion_prices
      end
      event.extra_info['original_std_work_prices'].each do |id, price_tier_id|
        std_work = StandardizedWork.find id
        std_work.update_columns(price_tier_id: price_tier_id)
        std_work.flush_cached_promotion_prices
      end
    end
  end
end
