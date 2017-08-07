class IllustratorService::DemoWorkArgumentsGenerator
  include IllustratorService::Helpers

  def initialize(work)
    @work = work
  end

  def layer_arguments
    IllustratorService::LayerArgumentsGenerator.new(@work).generate
  end

  def generate
    {
      pageSize: {
        width: @work.work_spec.width,
        height: @work.work_spec.height
      },
      item: {
        image: print_image.path,
        layers: layer_arguments
      },
      exportAI: ai.path,
      exportPDF: pdf.path
    }
  end

  def print_image
    @print_image ||= save_to_tempfile(@work.print_image.url)
  end

  def ai
    @ai ||= Tempfile.new([@work.id.to_s, '.ai'])
  end

  def pdf
    @pdf ||= Tempfile.new([@work.id.to_s, '.pdf'])
  end

  def close
    print_image.try(:close!)
    ai.try(:close!)
    pdf.try(:close!)
  end
end
