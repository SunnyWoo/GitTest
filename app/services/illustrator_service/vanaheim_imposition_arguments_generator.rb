class IllustratorService::VanaheimImpositionArgumentsGenerator
  def initialize(*args)
    @item, @template_path, @image_path, @qrcode_path, @output_path, @labels = args
    @work = @item.order_item.itemable
  end

  def layer_arguments
    IllustratorService::LayerArgumentsGenerator.new(@work).generate
  end

  def generate
    {
      template: @template_path.to_s,
      item: {
        image: @image_path.to_s,
        layers: layer_arguments
      },
      qrcode: @qrcode_path.to_s,
      labels: @labels,
      output: @output_path.to_s
    }
  end
end
