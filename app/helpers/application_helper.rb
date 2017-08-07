module ApplicationHelper
  def flash_class(level)
    case level
    when :notice then 'info'
    when :error then 'danger'
    when :alert then 'warning'
    when :success then 'success'
    end
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'current' : ''
    link_to link_text, link_path, class: class_name
  end

  def confirm_message
    '確認要刪除嗎？這個動作將無法回復'
  end

  def link_to_add_fields(name, f, association, options = {})
    class_name = options.delete(:class) || 'btn btn-sm btn-success'
    new_object = f.object.send(association).klass.new
    id = new_object.object_id

    I18n.available_locales.each do |locale|
      new_object.translations.build(locale: locale)
    end if options.delete(:with_translations).to_b

    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + '_fields', f: builder)
    end

    link_to(name, '#', class: "#{class_name} add_fields", data: { id: id, fields: fields.delete("\n") }.merge(options))
  end

  def sortable_links(searcher, attributes, options = {})
    buffer = '<thead><tr>'
    klass = options[:klass] || model_class
    i18n_prefix = options.delete(:i18n_prefix)
    attributes.each do |attr|
      attr.delete!("\n")
      if attr =~ /^nosort\_(.+)$/
        buffer << content_tag(:th, klass.human_attribute_name($1), class: attr)
      else
        label = i18n_prefix.present? ? I18n.t("#{i18n_prefix}.#{attr}") : attr
        buffer << content_tag(:th, sort_link(searcher, attr, label), class: attr)
      end
    end
    buffer << '</tr></thead>'
    raw buffer
  end

  def calculate_percentage(amount, total)
    return 100 if total == 0
    ((amount.to_f / total.to_f) * 100).to_i
  end

  def render_price(price, currency_code: current_currency_code, precision: nil)
    precision ||= currency_code_precision(currency_code)
    number_to_currency(floor_price(price, currency_code: currency_code),
                       locale: currency_code_to_locale(currency_code),
                       precision: precision)
  end

  def render_price_twd(price, _currency_code: current_currency_code)
    render_price(price, currency_code: 'TWD')
  end

  def floor_price(price, currency_code:)
    return 0 unless price
    rate = case currency_code
           when 'TWD', 'JPY' then 1
           else 100.0
           end
    (price * rate).floor / rate
  end

  def currency_code_to_locale(currency_code)
    case currency_code
    when 'TWD' then 'zh-TW'
    when 'CNY' then 'zh-CN'
    when 'JPY' then 'ja'
    when 'HKD' then 'zh-HK'
    else            'en'
    end
  end

  # TODO: 修改 可以不用每次都去讀 db
  def currency_code_precision(currency_code)
    ct = CurrencyType.find_by(code: currency_code)
    ct ? ct.precision : 0
  end

  def render_datetime(string_datetime = nil)
    return if string_datetime.nil?
    l Time.zone.parse(string_datetime), format: :short
  end

  def render_order_status_color(order_status = nil)
    return if order_status.nil?
    'unpaid' if order_status != 'paid'
  end

  # render_hide_class
  # 帶入 true 回傳 hide
  # 帶入 false 回傳 nil
  #
  # @param is_true [boolean] true or false
  #
  # @return [String] hide or ''
  def render_hide_class(is_true)
    is_true ? 'hide' : nil
  end

  def render_singularize(text, number)
    number.to_i == 1 ? text.singularize : text
  end

  def normal_user_signed_in?
    user_signed_in? && current_user.normal?
  end

  def render_yes_or_no(boolean)
    boolean ? t('shared.wordings.yes') : t('shared.wordings.no')
  end

  def render_model_print_items_count(model_id, aasm_state = 'pending')
    PrintItem.includes(order_item: :order).ransack(order_item_order_aasm_state_eq: 'paid',
                                                  aasm_state_eq: aasm_state,
                                                  model_id_eq: model_id).result.count
  end

  def render_category_print_items_count(category_id, aasm_state = 'pending')
    product_ids = current_factory.product_models.where(category_id: category_id).pluck(:id)
    PrintItem.ransack(order_item_order_aasm_state_eq: 'paid',
                     aasm_state_eq: aasm_state,
                     model_id_in: product_ids).result.count
  end

  def devise_is(user_agent)
    if user_agent =~ /iPhone/i
      'iPhone'
    elsif user_agent =~ /Android/i
      'Android'
    end
  end

  def edit_translator(key, options = {})
    if admin_signed_in?
      escape_key = key.tr('.', '|')
      i18n = content_tag(:span, t(key, options))
      edit_icon = fa_icon('edit',
                          class: 'translator-edit',
                          data: { 'translation-url' => admin_translation_path(escape_key) })
      i18n + edit_icon
    else
      t(key)
    end
  end
  alias_method :et, :edit_translator

  def render_gender_values
    [edit_translator('page.user.profile_attrs.gender_male'),
     edit_translator('page.user.profile_attrs.gender_female'),
     edit_translator('page.user.profile_attrs.gender_unspecified')]
  end

  def render_apple_itunes_app_meta
    argument = @app_url ? ", app-argument=#{@app_url}" : nil
    set_meta_tags 'apple-itunes-app' => "app-id=898632563#{argument}"
  end

  def product_model_list
    ProductModel.sellable_on('website').model_list
  end

  def deeplink(link)
    "#{Settings.deeplink_protocol}://#{link}"
  end

  def render_order_itemable_name(itemable)
    if itemable.is_a? ArchivedWork
      itemable.name || itemable.original_work.try(:name)
    else
      itemable.name
    end
  end

  def in_wexin?
    (user_agent.to_s.scan /micromessenger/i).present?
  end

  def store_support_phone
    if Region.china?
      I18n.t('store.support.phone', locale: 'zh-CN')
    else
      I18n.t('store.support.phone')
    end
  end

  def store_support_business_time
    if Region.china?
      I18n.t('store.support.business_time', locale: 'zh-CN')
    else
      I18n.t('store.support.business_time')
    end
  end
end
