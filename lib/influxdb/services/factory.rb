module Influxdb::Services
  class Factory
    attr_reader :value, :timestamp

    # isf = Influxdb::Services::Factory.new(Logcraft::Activity.last.as_json)
    # iss.push('log', {region: 'taiwan'}, isf.value)
    def initialize(opts = {})
      @value = parse_params(opts)
      @timestamp = opts.fetch('created_at', Time.now.utc)
    end

    private

    def parse_params(params)
      params.each_with_object({}) do |(k, v), m|
        v = parse_params(v) if v.is_a? Hash
        next unless v
        case v
        when Hash
          v.map { |key, value| m["#{k}.#{key}"] = value }
        when Integer
          m[k] = v
        when Float
          m[k] = v
        else
          m[k] = v.to_s
        end
      end
    end
  end
end
