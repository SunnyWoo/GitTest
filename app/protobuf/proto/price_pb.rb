module Proto
  class PricePb < ::Protobuf::Message; end

  class PricePb
    optional :float, :TWD, 1
    optional :float, :USD, 2
    optional :float, :JPY, 3
    optional :float, :HKD, 4
    optional :float, :CNY, 5
  end
end
