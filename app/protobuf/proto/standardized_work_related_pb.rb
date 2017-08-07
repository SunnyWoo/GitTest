module Proto
  class MetaPb < ::Protobuf::Message; end
  class RelatedWorkPb < ::Protobuf::Message; end
  class StandardizedWorkRelatedPb < ::Protobuf::Message; end

  class MetaPb
    optional :int32, :series_count, 1
    optional :int32, :designer_count, 2
    optional :int32, :recommend_count, 3
  end

  class RelatedWorkPb
    repeated WorkPb, :series_works, 1
    repeated WorkPb, :designer_works, 2
    repeated WorkPb, :recommend_works, 3
  end

  class StandardizedWorkRelatedPb
    optional RelatedWorkPb, :related_works, 1
    optional MetaPb, :meta, 2
  end
end
