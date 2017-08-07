module Proto
  class PreviewPb < ::Protobuf::Message; end

  class PreviewPb
    optional :int32, :id, 1
    optional :string, :normal, 2
    optional :string, :thumb, 3
    optional :string, :key, 4
    optional :string, :url, 5
    optional :string, :image_url, 6
    optional :int32, :position, 7
  end
end
