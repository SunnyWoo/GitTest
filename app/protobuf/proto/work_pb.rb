module Proto
  class OrderImagePb < ::Protobuf::Message; end
  class WorkPb < ::Protobuf::Message; end

  class OrderImagePb
    optional :string, :thumb, 1
    optional :string, :share, 2
    optional :string, :sample, 3
    optional :string, :normal, 4
  end

  class WorkPb
    optional :int32, :id, 1
    optional :string, :gid, 2
    optional :string, :uuid, 3
    optional :string, :name, 4
    optional :int32, :user_id, 5
    optional UserAvatarPb, :user_avatar, 6
    optional OrderImagePb, :order_image, 7
    repeated PreviewPb, :gallery_images, 8
    optional PricePb, :prices, 9
    optional PricePb, :original_prices, 10
    optional :string, :user_display_name, 11
    optional :bool, :wishlist_included, 12
    optional :string, :slug, 13
    optional :bool, :is_public, 14
    optional UserAvatarPb, :user_avatars, 15
    optional ProductModelPb, :product, 16
    optional ProductCategoryPb, :category, 17
    optional :bool, :featured, 18
    repeated LayerPb, :layers, 19
    repeated TagPb, :tags, 20
  end
end
