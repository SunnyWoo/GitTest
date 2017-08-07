class IllustratorService::AlfheimImpositionArgumentsGenerator
  include IllustratorService::Utils

  attr_reader :imposition
  delegate :labels, to: :imposition

  def initialize(imposition, items)
    @imposition = imposition
    @items = items
    @template_path = Rails.root.join(imposition.download_template).to_s
    @output_path = Rails.root.join("tmp/#{filename}").to_s
    @generated = false
  end

  def layer_arguments
    IllustratorService::LayerArgumentsGenerator.new(@work).generate
  end

  def generate
    @generated = true

    @ans ||= {
      template: @template_path.to_s,
      items: @items.map { |item|
        work = item.order_item.itemable
        args = IllustratorService::WorkArgumentsGenerator.new(work).generate
        args.merge!(
          qrcode: Rails.root.join(build_qrcode(item)).to_s,
          labels: localized_labels(item)
        )
      },
      output: @output_path.to_s
    }
  end

  def filename
    "#{@items.map(&:id).join('_')}.pdf"
  end

  def clean
    if @generated
      begin
        @ans[:items].each do |item|
          File.delete(item[:qrcode]) if File.exist?(item[:qrcode])
          File.delete(item[:image]) if File.exist?(item[:image])
        end
      rescue => e
        Rails.logger.debug e.message
        Rails.logger.debug e.backtrace
        raise e if Rails.env.development?
      end
    end

    true
  end
end
