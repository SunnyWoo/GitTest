class Campaign::WaterpackageWorkService

  SCHEMA = YAML.load_file(Rails.root.join('config','campaign_waterpackage.yml').to_s)

  class << self
    def logger
      @logger ||= Logger.new(Rails.root.join('log','waterpackage.log').to_s)
    end
  end

  def initialize(work_id, payload)
    @work = Work.find(work_id)
    @payload = payload
  end

  def perform
    ActiveRecord::Base.transaction do
      @work.layers.destroy_all
      data = Hash(@payload[0])

      schema['layers'].each do |layer_attrs|
        @work.layers.build(layer_attrs)
      end

      schema['text_groups'].each do |group|
        value = data[group['key']]
        group['layers'].each_with_index do |layer_attrs, i|
          word = value[i]
          next if word.blank?
          @work.layers.build(layer_attrs.merge(layer_type: 'text', font_text: word))
        end
      end

      @work.save!
      @work.reload
      @work.enqueue_build_print_image

      # Recopy layers to archived work
      aw = @work.archives.last
      if aw
        aw.layers.destroy_all
        aw.update(layers_attributes: @work.layers.map(&:archived_attributes))
        aw.enqueue_build_print_image
      end
    end
  end

  def schema
    SCHEMA
  end
end
