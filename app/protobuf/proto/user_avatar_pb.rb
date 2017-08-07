module Proto
  class Webp < ::Protobuf::Message; end
  class S35 < ::Protobuf::Message; end
  class S114 < ::Protobuf::Message; end
  class S115 < ::Protobuf::Message; end
  class Avatar < ::Protobuf::Message; end
  class UserAvatarPb < ::Protobuf::Message; end

  class Webp
    optional :string, :url, 1
  end

  class S35
    optional :string, :url, 1
  end

  class S114
    optional :string, :url, 1
  end

  class S115
    optional :string, :url, 1
  end

  class Avatar
    optional :string, :url, 1
    optional Webp, :webp, 2
    optional S35, :s35, 3
    optional S114, :s114, 4
    optional S115, :s154, 5
  end

  class UserAvatarPb
    optional Avatar, :avatar, 1
    optional :string, :s35, 2
    optional :string, :s154, 3
  end
end
