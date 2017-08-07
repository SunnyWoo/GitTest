class IllustratorService::WorkArgumentsGenerator
  include IllustratorService::Helpers

  def initialize(work)
    @work = work
  end

  def layer_arguments
    IllustratorService::LayerArgumentsGenerator.new(@work).generate
  end

  def generate
    {
      image: print_image.path,
      layers: layer_arguments
    }
  end

  def print_image
    @print_image ||= save_to_tempfile(@work.print_image.url)
  end

  def close
    print_image.try(:close!)
  end
end
