class Admin::DailyReportsController < AdminController
  helper_method :product_keys

  def show
  end

  def order_sticker
    find_order_stickers
    @data = OpenStruct.new(
      sticker_usage_trend:           sticker_usage_trend,
      sticker_usage_proportion:      sticker_usage_proportion,
      sticker_usage_growth_trend:    sticker_usage_growth_trend,
      sticker_usage_count_propotion: sticker_usage_count_propotion
    )
  end

  protected

  def find_order_stickers
    @starts_at = params[:starts_at].present? ? DateTime.parse(params[:starts_at]).in_time_zone : DateTime.current.beginning_of_month
    @ends_at = params[:ends_at].present? ? DateTime.parse(params[:ends_at]).in_time_zone : DateTime.current
    @order_stickers = Report::OrderSticker.between_times(@starts_at, @ends_at)
  end

  def product_keys
    params[:products].present? ? params[:products] : 'all'
  end

  def sticker_usage_trend
    columns = Layer::STICKER_TYPES.each_with_object([]) do |sticker_type, result|
      sticker_data_set = [sticker_type.humanize]
      @order_stickers.each_with_object(sticker_data_set) do |order_sticker, order_sticker_data_set|
        order_sticker_data_set << order_sticker.data.find { |row| row.key == sticker_type }.where(component: product_keys).sum.to_i
      end
      result << sticker_data_set
    end
    axis_x = axis_x(@order_stickers)
    title = "Sticker Usage Trend"
    {
      columns: columns,
      axis_x:  axis_x,
      title:   title
    }
  end

  def sticker_usage_proportion
    columns = Layer::STICKER_TYPES.each_with_object([]) do |sticker_type, result|
      sticker_data_set = [sticker_type.humanize]
      @order_stickers.each_with_object(sticker_data_set) do |order_sticker, order_sticker_data_set|
        order_sticker_data_set << order_sticker.data.find { |row| row.key == sticker_type }.where(component: product_keys).sum
        ./(order_sticker.sold_customized_order_items_layers_count(product_keys)).*(100).round(2)
      end
      result << sticker_data_set
    end
    axis_x = axis_x(@order_stickers)
    title = "Sticker Usage Proportion"
    {
      title: title,
      columns: columns,
      axis_x: axis_x
    }
  end

  def sticker_usage_growth_trend
    columns = Layer::STICKER_TYPES.each_with_object([]) do |sticker_type, result|
      result << @order_stickers.each_with_object([]) do |order_sticker, order_sticker_data_set|
        order_sticker_data_set << order_sticker.data.find { |row| row.key == sticker_type }.where(component: product_keys).sum.to_i
      end
    end
    columns = columns.each_with_object([]) do |sticker_data_set, result|
      result << []
      sticker_data_set.each_with_index do |_, index|
        break if index == sticker_data_set.length - 1
        result.last << (sticker_data_set[index + 1] - sticker_data_set[index]) / (@order_stickers[index + 1].created_at.to_date - @order_stickers[index].created_at.to_date).to_i
      end
    end
    Layer::STICKER_TYPES.each_with_index do |sticker, index|
      columns[index].unshift(sticker.humanize)
    end
    axis_x = []
    @order_stickers.each_with_index do |_, index|
      break if index == @order_stickers.length - 1
      axis_x << "#{@order_stickers[index].created_at.strftime('%d')} - #{@order_stickers[index + 1].created_at.strftime('%d')}"
    end
    title = 'Sticker Usage Growth Trend'
    {
      title: title,
      columns: columns,
      axis_x: axis_x
    }
  end

  def axis_x(stickers)
    stickers.each_with_object(['x']) do |order_sticker, result|
      result << order_sticker.created_at.strftime('%Y-%m-%d')
    end
  end

  def sticker_usage_count_propotion
    columns = Layer::STICKER_TYPES.each_with_object([]) do |sticker_type, result|
      sticker_data_set = []
      @order_stickers.each_with_object(sticker_data_set) do |order_sticker, order_sticker_data_set|
        order_sticker_data_set << order_sticker.data.find { |row| row.key == sticker_type }.where(component: product_keys).sum.to_i
      end
      result << [sticker_type.humanize, sticker_data_set.reduce(:+)]
    end
    {
      title: 'Sticker Usage Count Proportion',
      columns: columns
    }
  end
end
