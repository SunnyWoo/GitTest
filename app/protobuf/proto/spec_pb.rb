module Proto
  class SpecPb < ::Protobuf::Message; end

  class SpecPb
    optional :int32, :id, 1
    optional :string, :name, 2
    optional :string, :description, 3
    optional :string, :width, 4
    optional :string, :height, 5
    optional :string, :dpi, 6
    optional :string, :background_image, 7
    optional :string, :overlay_image, 8
    optional :string, :padding_top, 9
    optional :string, :padding_right, 10
    optional :string, :padding_bottom, 11
    optional :string, :padding_left, 12
    optional :string, :__deprecated, 13
  end
end
