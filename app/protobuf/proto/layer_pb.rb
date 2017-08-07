module Proto
  class Image < ::Protobuf::Message; end
  class MaskedLayer < ::Protobuf::Message; end
  class LayerPb < ::Protobuf::Message; end

  class Image
    optional :string, :normal, 1
    optional :string, :md5sum, 2
  end

  class MaskedLayer
    optional :int32, :id, 1
    optional :string, :uuid, 2
  end

  class LayerPb
    optional :int32, :id, 1
    optional :string, :uuid, 2
    optional :string, :layer_type, 3
    optional :string, :position_x, 4
    optional :string, :position_y, 5
    optional :string, :orientation, 6
    optional :string, :scale_x, 7
    optional :string, :scale_y, 8
    optional :string, :transparent, 9
    optional :string, :color, 10
    optional :string, :material_name, 11
    optional :string, :font_name, 12
    optional :string, :font_text, 13
    optional :string, :text_alignment, 14
    optional :string, :text_spacing_x, 15
    optional :string, :text_spacing_y, 16
    optional Image, :image, 17
    optional :string, :filter, 18
    optional Image, :filtered_image, 19
    optional :string, :position, 20
    optional :bool, :masked, 21
    repeated MaskedLayer, :masked_layers, 22
  end
end
