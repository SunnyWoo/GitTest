module Proto
  class PlatformPb < ::Protobuf::Message; end
  class ProductModelPb < ::Protobuf::Message; end

  class PlatformPb
    optional :bool, :android, 1
    optional :bool, :ios, 2
    optional :bool, :website, 3
  end

  class ProductModelPb
    optional :int32, :id, 1
    optional :string, :key, 2
    optional :string, :name, 3
    optional :string, :description, 4
    optional PricePb, :prices, 5
    optional PricePb, :customized_special_prices, 6
    optional PlatformPb, :design_platform, 7
    optional PlatformPb, :customize_platform, 8
    optional :string, :placeholder_image, 9
    optional :float, :width, 10
    optional :float, :height, 11
    optional :float, :dpi, 12
    optional :string, :background_image, 13
    optional :string, :overlay_image, 14
    optional :float, :padding_top, 15
    optional :float, :padding_right, 16
    optional :float, :padding_bottom, 17
    optional :float, :padding_left, 18
    repeated SpecPb, :specs, 19
  end
end
