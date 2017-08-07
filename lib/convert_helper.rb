module ConvertHelper
  # Avoid Elasticsearch Mapping Explosion
  def convert_params(params)
    params.inject([]) do |memo, (k, v)|
      v = convert_params(v) if v.is_a? Hash
      case v
      when String
        memo << { 'key' => k, 'value' => v.length > 250 ? "#{v[0...250]}...[Skip]" : v }
      when Integer, Fixnum
        memo << { 'key' => k, 'value' => v }
      else
        memo << { 'key' => k, 'value' => v.to_s }
      end
    end
  end
end
