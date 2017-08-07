class IllustratorService::LayerArgumentsGenerator
  include IllustratorService::Helpers

  # AI 裡面都是 72 DPI
  AI_DPI = 72.0

  def initialize(work)
    @work = work
  end

  def rate
    @rate ||= AI_DPI / @work.work_spec.dpi
  end

  def generate
    if @work.respond_to?(:layers)
      @work.layers.map { |layer| generate_arguments_for_layer(layer) }.compact
    else
      []
    end
  end

  def generate_arguments_for_layer(layer)
    case layer.layer_type
    when 'varnishing_typography'
      add_coating_argument(layer, layer.commandp_resources_material_path)
    when 'coating_asset'
      asset = Asset.find_by!(uuid: layer.material_name)
      asset_file = save_to_tempfile(asset.vector.url)
      add_coating_argument(layer, asset_file.path)
    when 'bronzing_typography'
      add_foiling_argument(layer, layer.commandp_resources_material_path)
    when 'foiling_asset'
      asset = Asset.find_by!(uuid: layer.material_name)
      asset_file = save_to_tempfile(asset.vector.url)
      add_foiling_argument(layer, asset_file.path)
    end
  end

  def add_coating_argument(layer, path)
    {
      type: 'coating',
      image: File.expand_path(path)
    }.merge(dimension_for_layer(layer))
  end

  def add_foiling_argument(layer, path)
    {
      type: 'foiling',
      image: File.expand_path(path)
    }.merge(dimension_for_layer(layer))
  end

  def dimension_for_layer(layer)
    {
      scaleX: layer.scale_x * rate * 100,
      scaleY: layer.scale_y * rate * 100,
      positionX: layer.position_x * rate,
      positionY: layer.position_y * rate,
      angle: -layer.orientation
    }
  end
end
