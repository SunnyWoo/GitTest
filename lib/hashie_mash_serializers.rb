require 'hashie/mash'

module HashieMashSerializers
  class PGJSONSerializer
    include Singleton

    def dump(mash)
      mash
    end

    def load(hash)
      Hashie::Mash.new(hash)
    end
  end

  # 產生一個可以存到 pg json 欄位的 Hashie::Mash, 以推翻 pg text 與 OpenStruct 的獨裁霸權
  #
  # 用法:
  #
  #     serialize :image_meta, Hashie::Mash.pg_json_serializer
  def pg_json_serializer
    PGJSONSerializer.instance
  end
end

Hashie::Mash.extend(HashieMashSerializers)
