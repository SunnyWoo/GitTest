module Proto
  class ProductCategoryPb < ::Protobuf::Message;
  end

  class ProductCategoryPb
    optional :int32, :id, 1
    optional :string, :key, 2
    optional :string, :name, 3
  end
end
