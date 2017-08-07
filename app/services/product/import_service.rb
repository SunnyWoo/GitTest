class Product::ImportService
  attr_accessor :product_attrs, :logs

  def initialize(json)
    @product_attrs = json
    @product_attrs = JSON.parse(json) unless @product_attrs.is_a?(Hash)
    @logs ||= []
  end

  def execute
    @product_attrs.each do |attrs|
      attrs = Hashie::Mash.new attrs
      check_product_category(attrs.category)
      handle_timeout(attrs)
    end
  end

  private

  # sidekiq timeout 為 60sec 這邊設定 比較小 50sec
  def handle_timeout(attrs)
    Timeout.timeout 50 do
      product = build_product_model(attrs.attributes, attrs.category['key'])
      if product
        build_preview_composers(attrs.preview_composers, product.id)
        logs << "build ProductModel key:#{product.key} Finish"
      end
    end
  rescue Timeout::Error => e
    logs << "Import product model time out error:#{e}"
  end

  def check_product_category(category)
    logs << "check_product_category key:#{category['key']}"
    unless ProductCategory.find_by(key: category['key'])
      c = ProductCategory.create(category)
      logs << "create ProductCategory key:#{c.key}"
    end
  end

  def build_product_model(attributes, category_key)
    attributes['category_id'] = ProductCategory.find_by(key: category_key).id
    attributes['factory_id'] = Factory.first.id
    product = ProductModel.find_or_initialize_by(key: attributes['key'])
    logs << (product.id.present? ? "find ProductModel key:#{product.key}" : "initialize ProductModel key:#{product.key}")
    product.attributes = attributes
    changes = product.changes
    if product.save
      logs << "update ProductModel key:#{product.key}"
      logs << changes
      product
    else
      logs << "build ProductModel key:#{product.key} fail"
      logs << product.errors.full_messages
      false
    end
  end

  def build_preview_composers(composers, product_id)
    logs << 'build_preview_composers'
    composers.map do |item|
      type = item.delete('type')
      composer = Object.const_get(type).find_or_initialize_by(key: item['key'], model_id: product_id)
      logs << (composer.id.present? ? "find #{type} key:#{composer.key}" : "initialize #{type} key:#{composer.key}")
      preview_composer_keys.each do |attrs|
        key = attrs.delete(:key)
        filename = attrs.delete(:filename)
        composer.send("#{key}=", build_dispatch_file(filename, item.delete(key))) if item.key?(key)
      end

      composer.attributes = item
      changes = composer.changes
      if composer.save
        logs << "update #{type} key:#{composer.key}"
        logs << changes
      else
        logs << "update #{type} key:#{composer.key} fail"
        logs << composer.errors.full_messages
        false
      end
    end
  end

  def preview_composer_keys
    [
      { key: 'case_file', filename: 'case.png' },
      { key: 'mask_file', filename: 'mask.png' },
      { key: 'left_mask_file', filename: 'left.png' },
      { key: 'right_mask_file', filename: 'right.png' },
      { key: 'image_file', filename: 'image.png' },
      { key: 'background_file', filename: 'background.png' }
    ]
  end

  def build_dispatch_file(filename, url)
    ActionDispatch::Http::UploadedFile.new(filename: filename, tempfile: MiniMagick::Image.open(url))
  end
end
