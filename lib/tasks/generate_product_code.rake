namespace :generate_product_code do
  task :generate, [:region] => :environment do |_t, args|
    invalid_data = []
    ProductModel.all.find_each do |product|
      product.send(:generate_code)
      product.save
    end

    Designer.all.find_each do |designer|
      designer.send(:generate_code)
      designer.save
    end

    Work.includes(:work_code, product: [:category, :craft, :spec, :product_material]).with_deleted.find_each do |work|
      if work.product.blank?
        invalid_data << ['Work', work.id]
      else
        work.work_code.delete if work.work_code.present?
        work.send(:generate_work_code)
      end
    end

    StandardizedWork.includes(:work_code, product: [:category, :craft, :spec, :product_material]).with_deleted.find_each do |standardized_work|
      if standardized_work.product.blank?
        invalid_data << ['StandardizedWork', standardized_work.id]
      else
        standardized_work.work_code.delete if standardized_work.work_code.present?
        standardized_work.send(:generate_work_code)
      end
    end

    # china站 没有 original_work_id 則按照`抛单`商品的编码规则来处理
    if args[:region] == 'china'
      ArchivedWork.includes(:product).all.find_each do |aw|
        if aw.original_work_id.present?
          aw.update(product_code: aw.original_work.try(:product_code))
        else
          product_code = "#{aw.product.try(:product_code)}-0001-000"
          aw.update(product_code: product_code)
        end
      end
    end

    if args[:region] == 'global'
      ArchivedWork.includes(:product).all.find_each do |aw|
        aw.update(product_code: aw.original_work.try(:product_code))
      end
    end

    ArchivedStandardizedWork.includes(:product).all.find_each do |asw|
      asw.update(product_code: asw.original_work.try(:product_code))
    end

    p invalid_data
  end
end
