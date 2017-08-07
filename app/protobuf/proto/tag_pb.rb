module Proto
  class TagPb < ::Protobuf::Message; end

  class TagPb
    optional :int32, :id, 1
    optional :string, :name, 2
    optional :string, :text, 3
  end
end
