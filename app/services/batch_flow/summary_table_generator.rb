class BatchFlow::SummaryTableGenerator
  include BatchFlow::Utils

  attr_reader :rows

  def initialize(batch, print_items, options = {})
    raise ArgumentError unless print_items.all?{ |x| x.is_a?(BatchFlow::FileDumpService::SerialItem) }
    @batch, @options = batch, options
    gi = print_items.group_by(&:is_reprint?)
    @reprint_items = Array(gi[true])
    @normal_items = Array(gi[false])
  end

  def generate!
    @rows = [header]
    @reprint_items.any? && append_rows(@reprint_items)
    @normal_items.any? && append_rows(@normal_items)

    append_product_stat(@reprint_items + @normal_items)

    generate_file!

    destination
  end

  def destination; "#{path}/#{filename}.csv"; end

  def path; @options.fetch(:path, 'tmp'); end

  def filename
    @options.fetch(:filename){
      I18n.t('filename', scope: i18n_scope, batch_number: @batch.number, source: source_location_code)
    }
  end

  def header
    %w(
      batch_number
      deadline
      location
      item_number
      order_number
      product_name
      quantity
      shipping_number
      note
    ).map { |name| I18n.t("header.#{name}", scope: i18n_scope) }
  end

  private

  def generate_file!
    CSV.open(destination, "wb") do |csv|
      @rows.each { |row| csv << row }
    end
  end

  def append_rows(print_items)
    groups = print_items.group_by { |i|
      i.order_item.order
    }.map { |order, items| OrderRowsGroup.new(@batch, order, items) }

    groups.each do |group|
      @rows += group.to_rows
    end
  end

  def append_product_stat(items)
    @rows << []
    @rows << [I18n.t('header.stat_title', scope: i18n_scope)]
    @rows << [I18n.t('header.stat_product', scope: i18n_scope), I18n.t('header.stat_quantity', scope: i18n_scope)]

    items.group_by(&:product).each do |product, data|
      @rows << [product.name, data.size]
    end
  end

  def i18n_scope; 'print.batch_flow.summary_table'; end

  class OrderRowsGroup
    include BatchFlow::Utils

    def initialize(batch, order, print_items)
      @batch, @order = batch, order
      @order_items = print_items.group_by(&:order_item)
    end

    def to_rows
      @rows = []
      @order_items.each do |_, print_items|
        product = print_items[0].product
        item = print_items[0]
        quantity = print_items.size
        item_code = generate_item_code(@order, item.order_item_serial, product, quantity)
        @rows << [
          @batch.number_with_source,
          @batch.deadline.to_date.to_s,
          source_location_code,
          item_code,
          @order.order_no,
          product.name,
          quantity,
          '',
          item.is_reprint? ? I18n.t('print.batch_flow.summary_table.is_reprint') : ''
        ]
      end
      @rows
    end
  end
end
