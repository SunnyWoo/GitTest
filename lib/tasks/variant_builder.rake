namespace :variant_builder do
  task build: :environment do
    WorkSpec.delete_all
    Variant.delete_all

    ProductModel.find_each do |product|
      product.build_variant
      # 有些print_image_mask不符合设定， 先允许迁移过来吧
      product.variants.first.save(validate: false)
    end
  end
end
