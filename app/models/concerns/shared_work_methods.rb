module SharedWorkMethods
  extend ActiveSupport::Concern
  include HasPromotionPrice

  included do
    extend CarrierWave::Meta::ActiveRecord
    extend FriendlyId
    include Logcraft::Trackable
    include HasUniqueUUID
    include PreprocessImage
    include Work::ImplicitVariant

    serialize :image_meta, Hashie::Mash.pg_json_serializer

    belongs_to :user, polymorphic: true
    belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id
    belongs_to :variant
    has_many :order_items, as: :itemable
    has_one :category, through: :product
    scope :with_available_product, -> { joins(:product).merge(ProductModel.available) }
    scope :with_sellable_on_product, (lambda do |platform|
      joins(:product).where('"product_models"."design_platform" ->> :platform = :result',
                            platform: platform, result: 'true')
    end)
    scope :recent, -> { order('created_at DESC') }

    after_update :touch_order_items
    after_save :build_white_version, if: :print_image_changed?
  end

  delegate :work_spec, to: :variant
  delegate :display_name, :avatar, to: :user, prefix: true
  delegate :name, :description, :width, :height, :dpi, :dpi_width, :dpi_height, :enable_composite_with_horizontal_rotation, to: :product, prefix: true
  delegate :price_in_currency, to: :product
  delegate :key, to: :product, prefix: true

  def build_print_image
    flag = work_spec.enable_composite_with_horizontal_rotation?
    image = ImageService::MiniMagick.new(self).generate(mirror_image: flag)

    # 雙面拼接模式的work必須要有一張未雙面拼接合成的圖片保留起來以去製造order_image
    if flag
      Rails.logger.debug 'Generate the original print_image without watermark and mirror composition, and save that to work preview with key original_image_without_watermark...'
      original_image_without_watermark = ImageService::MiniMagick.new(self).generate(skip_watermark: true)
      preview = previews.where(key: Preview::ORIGINAL_PRINT_IMAGE_KEY).first_or_initialize
      preview.image = original_image_without_watermark
      preview.save!
    end
    update_print_image(image)
  end

  def build_white_version
    return unless work_spec.enable_white? && print_image_is_an_image?
    print_image.recreate_versions!(:gray)
  end

  def enqueue_build_print_image
    PrintImageBuilder.perform_async(to_gid)
  end

  def build_ai
    IllustratorService.new.build_demo_work_for_ai(self)
  end

  def enqueue_build_ai
    AiBuilder.perform_async(to_gid)
  end

  def touch_order_items
    order_items.each(&:touch)
  end

  def same_design
    self.class.with_available_product.is_public
        .ransack(name_eq: name, id_not_eq: id).result
  end

  def authorize?(current_user)
    (user == current_user) || is_public?
  end

  def update_print_image(image)
    if print_image.model.is_a?(WorkOutputFile)
      output_files.find_by(key: 'print-image').update(file: image)
    else
      update(print_image: image)
    end
  end

  def print_image_is_an_image?
    print_image.content_type =~ /image/
  end

  # for build_print_image 使用
  def build_fake_layers
    return unless print_image.present?
    layer_params = { layer_type: :fake,
                     uuid: UUIDTools::UUID.timestamp_create.to_s,
                     scale_x: 0.5,
                     scale_y: 0.5,
                     position: 1,
                     filtered_image: print_image.file,
                     image: print_image.file }
    Array(Layer.new(layer_params))
  end

  # implement interface for HasPromotionPrice
  def special_prices
    prices
  end

  def active_promotions
    @active_promotions ||= begin
      ap = case self
           when StandardizedWork
             promotions.item_level.available
           when ArchivedStandardizedWork
             original_work.present? ? original_work.promotions.item_level.available : []
           else
             []
           end

      (ap + product.active_promotions).uniq.sort_by(&:begins_at)
    end
  end

  def product_template_exist?
    try(:product_template).present?
  end

  def share_preview
    'not support yet'
  end

  def download_preview
    'not support yet'
  end

  def ordered_previews
    'not support yet'
  end

  module ClassMethods
    def policy_class
      WorkPolicy
    end
  end
end
