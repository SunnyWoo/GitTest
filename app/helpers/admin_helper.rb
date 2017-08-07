module AdminHelper
  def render_standardized_work_print_image(work)
    if work.print_image.file.try(:extension) == 'pdf'
      link_to '下載檔案', work.print_image.url, target: '_blank'
    else
      display_image(work.print_image)
    end
  end

  def display_true_or_false_icon(is_enabled)
    is_enabled.to_b ? fa_icon('check', class: 'green') : fa_icon('close', class: 'red')
  end

  def display_cover_image(work)
    display_image(work.cover_image, blank_message: '(無)')
  end

  def display_white_image(work)
    display_image_with_url(work.print_image.gray.url)
  end

  def display_print_image(work, lazy: true)
    display_image(work.print_image, lazy: lazy)
  end

  def rebuild_print_image_link(work)
    options = { id: dom_id(work, :pib),
                class: 'btn btn-default btn-minier',
                method: 'post',
                remote: true }
    link_to t('helper.rebuild_print_image_link'), [:admin, work, :print_image], options
  end

  def remove_fixed_image_link(work)
    return if work.try(:fixed_image).blank?
    options = { id: dom_id(work, :rfi),
                class: 'btn btn-default btn-minier',
                method: 'delete',
                remote: true }
    link_to t('helper.remove_fixed_image'), [:admin, work, :fixed_image], options
  end

  def rebuild_order_image_link(work)
    options = { id: dom_id(work, :oib),
                class: 'btn btn-default btn-minier',
                method: 'post',
                remote: true }
    link_to t('helper.rebuild_order_image_link'), [:admin, work, :order_image], options
  end

  def rebuild_ai_link(work)
    options = { id: dom_id(work, :ai), class: 'btn btn-default btn-minier', method: 'post', remote: true }
    link_to t('helper.rebuild_ai_link'), [:admin, work, :ai], options
  end

  def display_order_image(work)
    display_image(work.order_image)
  end

  def display_image(image, blank_message: '(還未產生)', lazy: true)
    if image.blank?
      blank_message
    else
      lazy_class = lazy ? 'lazy' : ''
      img = image_tag(image.thumb.url, class: "#{lazy_class} work_thumb_image dashed-border", lazy: lazy)
      link_to img, image.url, target: '_blank', class: 'popup-image'
    end
  end

  def display_image_with_url(image_url, width: 100)
    img = image_tag(image_url, class: 'lazy dashed-border', width: width, lazy: true)
    link_to img, image_url, target: '_blank', class: 'popup-image'
  end

  def active_for_current_page(li_type)
    case li_type
    when 'public'
      'active' if params[:q].present? && params[:q][:work_type_eq] == '0'
    when 'special price'
      'active' if params[:q].present? && params[:q][:price_tier_id_null] == '0'
    when 'private'
      'active' if params[:q].present? && params[:q][:work_type_eq] == '1'
    when 'finished'
      'active' if params[:q].present? && params[:q][:finished_eq] == '1'
    when 'feature'
      'active' if params[:q].present? && params[:q][:feature_eq].present?
    when 'all'
      'active' if !params[:q].present? && params[:controller] == 'admin/works' && !params[:deleted].to_b
    when 'standardized'
      'active' if params[:controller] == 'admin/standardized_works'
    when 'archived'
      'active' if params[:controller] == 'admin/archived_works'
    when 'deleted'
      'active' if params[:deleted].to_b
    end
  end

  def order_state_options(order)
    options_for_select(order.aasm.states.map(&:name))
  end

  def current_admin_username
    current_admin.email.split('@').first
  end

  def admin_sidebar_link(*args, &block)
    if block_given?
      url, icon = args
      text = capture(&block)
    else
      text, url, icon = args
    end
    render 'admin/v2/shared/sidebar_link', text: text, url: url, icon: icon
  end

  def auto_link_with_nl2br(text)
    auto_link(text, html: { target: '_blank' }).gsub(/\n/, '<br />').html_safe
  end

  def admin_avatar_for(model)
    image_url = case model
                when Admin then model.gravatar_url
                when User  then model.avatar_url
                else            path_to_image('robot.png')
                end
    image_tag(image_url)
  end

  def admin_username_for(model)
    case model
    when Admin    then model.email.split('@').first
    when User     then model.username
    when Designer then model.display_name
    when Factory  then model.name
    when FactoryMember then model.username
    else 'SYSTEM'
    end
  end

  def render_print_image_warning(origin_number, verify_number)
    return nil if verify_number.nil? || origin_number.nil?
    safe_number = 3 # 正負範圍
    if verify_number > (origin_number + safe_number)
      gt = verify_number - origin_number
      content_tag(:span, "太寬 多：#{gt}", class: 'label label-warning label-large')
    elsif (verify_number < (origin_number - safe_number))
      lt = origin_number - verify_number
      content_tag(:span, "太窄 少：#{lt}", class: 'label label-warning label-large')
    end
  end

  def xeditable?(_object = nil)
    true # Or something like current_user.xeditable?
  end

  def render_order_unapproved_count
    Order.paid.where(approved: false).count
  end

  def link_to_user(model)
    text = admin_username_for(model)
    href = [:admin, model]
    link_to text, href
  end

  def render_payment_official_web(refund)
    case Rails.env
    when 'production'
      if refund.order.payment == 'stripe'
        link_to refund.refund_no, "https://dashboard.stripe.com/payments/#{refund.order.payment_id}", target: '_blank'
      elsif refund.order.payment == 'paypal'
        link_to refund.refund_no, 'https://developer.paypal.com/webapps/developer/dashboard/live', target: '_blank'
      end
    else
      if refund.order.payment == 'stripe'
        link_to refund.refund_no, "https://dashboard.stripe.com/test/payments/#{refund.order.payment_id}", target: '_blank'
      elsif refund.order.payment == 'paypal'
        link_to refund.refund_no, 'https://developer.paypal.com/webapps/developer/dashboard/test', target: '_blank'
      end
    end
  end

  def render_warning(msg = '', fa_icon = 'question-circle')
    content_tag(:span, fa_icon(fa_icon), class: 'pull-right red',
                                         title: msg, data: { rel: 'tooltip' })
  end

  def collection_for_factory_name_with_id
    Factory.all.map { |factory| [factory.name, factory.id] }
  end

  def render_sort_buttons(&_sort_url)
    render 'sort_buttons', sort_url: ->(sort) { yield(sort) }
  end

  def render_invoice_memo(invoice_memo)
    rows = ['訂單編號', '出貨日期', '訂單狀態(0 新單/1 修單/2 刪單)', '發票號碼',
            '發票日期', '發票狀態(開立、異常、作廢、待作廢、折讓、待折讓)', '二聯或三聯',
            '電子/捐贈/紙本', '稅率別', '發票未稅金額', '發票稅額', '發票含稅金 額',
            '買方統一編號', '異動日期']
    rows = rows.zip invoice_memo.split('|')
    rows.map { |row| content_tag(:div, "#{row[0]}：#{row[1]}") }.join('')
  end

  def render_package_category_status(boolean)
    boolean ? I18n.t('asset_package_categories.index.status.available') :
              I18n.t('asset_package_categories.index.status.unavailable')
  end

  def collection_for_package_category_status
    [
      [I18n.t('asset_package_categories.index.status.available'), true],
      [I18n.t('asset_package_categories.index.status.unavailable'), false],
      [I18n.t('shared.form_actions.both_ok'), nil]
    ]
  end

  def include_webpack_assets(source)
    styles, scripts = webpack_asset_paths(source).partition { |f| f =~ /\.css$/ }
    styles.map! { |style| stylesheet_link_tag(style) }
    scripts.map! { |script| javascript_include_tag(script) }
    (styles + scripts).join.html_safe
  end

  def collection_for_product_model
    ProductModel.available.pluck(:name, :id)
  end

  def options_for_marketing_report_type
    array = MarketingReport::GenerateService::ADAPTAERS.map do |report_type|
      [I18n.t("reports.report_type.#{report_type}"), report_type]
    end
    options_for_select(array)
  end

  def render_collection_for_designers
    Designer.ordered.map { |d| [d.display_name, d.id] }
  end

  def options_for_product_model_key
    array = ProductCategory.available.map(&:products).flatten.select(&:available).map do |product|
      [product.key.humanize, product.key]
    end
    options_for_select(array)
  end
end
