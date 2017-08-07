class BatchFlow::FileDumpService
  include BatchFlow::Utils

  def initialize(batch)
    @batch = batch
  end

  def perform!
    print_items = wrap_items(load_print_items)

    products_with_items = print_items.group_by(&:product)

    @temp_dir = mktmpdir
    @documents_path = "#{root_path}/document"
    @images_path = "#{root_path}/image"

    Dir.mkdir(root_path)
    Dir.mkdir(@documents_path)
    Dir.mkdir(@images_path)

    # Batch by Product
    products_with_items.each do |product, items|
      generate_product_directory(product, items)
    end

    # Generate Summary Table(CSV)
    csv = BatchFlow::SummaryTableGenerator.new(@batch, print_items, path: @documents_path)
    csv.generate!

    root_path
  end

  def generate_product_directory(product, print_items)
    product_images_path = "#{@images_path}/#{product.name.tr('/', '_')}"
    Dir.mkdir(product_images_path) unless File.exist?(product_images_path)

    # Generate Worksheet(PDF)
    pdf = BatchFlow::WorksheetGenerator.new(@batch, product, print_items, path: @documents_path)
    pdf.generate!

    # Generate Print Image with Directory by Order
    print_items.group_by(&:order_item).each do |_, items|
      copy_print_image(product_images_path, product, items)
    end

    true
  end

  def clean
    return unless @temp_dir && File.exist?(@temp_dir)
    FileUtils.rm_rf @temp_dir
  end

  private

  def root_path
    "#{@temp_dir}/#{source_location_code}#{@batch.number}"
  end

  def copy_print_image(path, product, grouped_items)
    print_item = grouped_items[0]
    order_item = print_item.order_item

    source = order_item.itemable.print_image.url
    source = URI.escape(source)
    extension = File.extname(URI.parse(source).path)
    quantity = grouped_items.size

    filename = generate_item_code(order_item.order, print_item.order_item_serial, product, quantity)
    destination = "#{path}/#{filename}#{extension}"

    File.open(destination, 'wb') { |file| file.write open(source).read }
  end

  def load_print_items
    PrintItem.includes(product: :translations, order_item: :order).
      where(id: @batch.print_item_ids).order('orders.order_no')
  end

  # Computed the serial numbers and stored in items
  def wrap_items(print_items)
    ans = []
    print_items.group_by{ |x| x.order_item.order }.each do |_, pitems|
      pitems.group_by(&:order_item).each_with_index do |(_, items), order_item_index|
        items.each_with_index do |item, quantity_index|
          item = item.becomes(SerialItem)
          item.order_item_serial = order_item_index.succ
          item.quantity_serial = quantity_index.succ
          ans << item
        end
      end
    end
    ans
  end

  def mktmpdir
    dirname = "BATCH_#{@batch.id}_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}"
    path = Rails.root.join('tmp', dirname).to_s
    Dir.mkdir(path)
    path
  end

  class SerialItem < ::PrintItem
    attr_accessor :order_item_serial, :quantity_serial
    def readonly?; true; end
  end
end
