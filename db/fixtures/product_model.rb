return if Rails.env.test?

require 'seed-fu'

rows = YAML.load(File.read('db/fixtures/data/product_models.yml'))
rows.each do |key, product_rows|
  product_category_id = ProductCategory.find_by(key: key).id
  product_rows.each { |row| row['category_id'] = product_category_id }
  ProductModel.seed_once(:key, product_rows)
end

rows = YAML.load(File.read('db/fixtures/data/product_model_translations.yml'))
rows.each do |key, translation_rows|
  product_id = ProductModel.find_by(key: key).id
  translation_rows.each { |row| row['product_model_id'] = product_id }
  ProductModel::Translation.seed_once(:product_model_id, :locale, translation_rows)
end

Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 249,
                     payable_id: ProductModel.find_by(key: 'wood_white_clocks').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 32.95,
                     payable_id: ProductModel.find_by(key: 'wood_white_clocks').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 979,
                     payable_id: ProductModel.find_by(key: 'wood_white_clocks').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 5480,
                     payable_id: ProductModel.find_by(key: 'wood_white_clocks').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 899,
                     payable_id: ProductModel.find_by(key: 'samsung_note3_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 29.95,
                     payable_id: ProductModel.find_by(key: 'samsung_note3_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 3480,
                     payable_id: ProductModel.find_by(key: 'samsung_note3_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 229,
                     payable_id: ProductModel.find_by(key: 'samsung_note3_cases').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 899,
                     payable_id: ProductModel.find_by(key: 'samsung_s5_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 29.95,
                     payable_id: ProductModel.find_by(key: 'samsung_s5_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 3480,
                     payable_id: ProductModel.find_by(key: 'samsung_s5_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 229,
                     payable_id: ProductModel.find_by(key: 'samsung_s5_cases').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 899,
                     payable_id: ProductModel.find_by(key: 'samsung_s4_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 29.95,
                     payable_id: ProductModel.find_by(key: 'samsung_s4_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 3480,
                     payable_id: ProductModel.find_by(key: 'samsung_s4_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 229,
                     payable_id: ProductModel.find_by(key: 'samsung_s4_cases').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 1279,
                     payable_id: ProductModel.find_by(key: 'ipad_air_covers').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 42.95,
                     payable_id: ProductModel.find_by(key: 'ipad_air_covers').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 4880,
                     payable_id: ProductModel.find_by(key: 'ipad_air_covers').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 329,
                     payable_id: ProductModel.find_by(key: 'ipad_air_covers').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 1279,
                     payable_id: ProductModel.find_by(key: 'ipad_mini_covers').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 42.95,
                     payable_id: ProductModel.find_by(key: 'ipad_mini_covers').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 4880,
                     payable_id: ProductModel.find_by(key: 'ipad_mini_covers').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 329,
                     payable_id: ProductModel.find_by(key: 'ipad_mini_covers').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 499,
                     payable_id: ProductModel.find_by(key: 'mugs').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 16.9,
                     payable_id: ProductModel.find_by(key: 'mugs').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 1780,
                     payable_id: ProductModel.find_by(key: 'mugs').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 129,
                     payable_id: ProductModel.find_by(key: 'mugs').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 349,
                     payable_id: ProductModel.find_by(key: 'easycard_smartcards').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 11.95,
                     payable_id: ProductModel.find_by(key: 'easycard_smartcards').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 1480,
                     payable_id: ProductModel.find_by(key: 'easycard_smartcards').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 89,
                     payable_id: ProductModel.find_by(key: 'easycard_smartcards').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 899,
                     payable_id: ProductModel.find_by(key: 'iphone_6plus_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 29.95,
                     payable_id: ProductModel.find_by(key: 'iphone_6plus_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 3480,
                     payable_id: ProductModel.find_by(key: 'iphone_6plus_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 229,
                     payable_id: ProductModel.find_by(key: 'iphone_6plus_cases').id,
                     payable_type: 'ProductModel'
                   }
                  )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 899,
                     payable_id: ProductModel.find_by(key: 'iphone_6_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 29.95,
                     payable_id: ProductModel.find_by(key: 'iphone_6_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 3480,
                     payable_id: ProductModel.find_by(key: 'iphone_6_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 229,
                     payable_id: ProductModel.find_by(key: 'iphone_6_cases').id,
                     payable_type: 'ProductModel'
                   }
                 )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 619,
                     payable_id: ProductModel.find_by(key: 'iphone_4_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 20.95,
                     payable_id: ProductModel.find_by(key: 'iphone_4_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 2180,
                     payable_id: ProductModel.find_by(key: 'iphone_4_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 149,
                     payable_id: ProductModel.find_by(key: 'iphone_4_cases').id,
                     payable_type: 'ProductModel'
                   }
                 )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 899,
                     payable_id: ProductModel.find_by(key: 'iphone_5_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 29.95,
                     payable_id: ProductModel.find_by(key: 'iphone_5_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 3480,
                     payable_id: ProductModel.find_by(key: 'iphone_5_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 229,
                     payable_id: ProductModel.find_by(key: 'iphone_5_cases').id,
                     payable_type: 'ProductModel'
                   }
                 )
Currency.seed_once(:code, :payable_id, :payable_type,
                   {
                     name: 'Taiwan New Dollar',
                     code: 'TWD',
                     price: 1499,
                     payable_id: ProductModel.find_by(key: 'ipad_mini_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'U.S. Dollar',
                     code: 'USD',
                     price: 49.95,
                     payable_id: ProductModel.find_by(key: 'ipad_mini_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Japanese Yen',
                     code: 'JPY',
                     price: 5380,
                     payable_id: ProductModel.find_by(key: 'ipad_mini_cases').id,
                     payable_type: 'ProductModel'
                   },
                   {
                     name: 'Hong Kong Dollar',
                     code: 'HKD',
                     price: 379,
                     payable_id: ProductModel.find_by(key: 'ipad_mini_cases').id,
                     payable_type: 'ProductModel'
                   }
                  )

factory = Factory.find_by code: "commandp"
ProductModel.where(factory_id: nil).update_all(factory_id: factory.id)

# update product_model slug
ProductModel.find_each(&:save)
