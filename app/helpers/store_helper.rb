module StoreHelper
  def store_sidebar_link(*args, &block)
    if block_given?
      url, icon = args
      text = capture(&block)
    else
      text, url, icon = args
    end
    render 'store/shared/sidebar_link', text: text, url: url, icon: icon
  end

  def render_store_layout_component_input_class(component, type)
    case type
    when 'image'
      if component.new_record?
        'store_layout_image hide'
      else
        ((component.key.in? StoreComponent::IMAGE_KEYS) ? 'store_layout_image' : 'store_layout_image hide')
      end
    when 'content'
      if component.new_record?
        'store_layout_content hide'
      else
        ((component.key.in? StoreComponent::CONTENT_KEYS) ? 'store_layout_content' : 'store_layout_content hide')
      end
    end
  end

  def collection_for_fonts_name
    CommandP::Resources.fonts.map { |font| [font.name.humanize, font.name] }
  end

  def render_collection_for_store_aasm
    ProductTemplate.aasm.states.map(&:name).map { |state| [state.to_s.humanize, state] }
  end

  def render_active_class_for_template_form_tab(type, template, default = false)
    return 'active' if default && template.template_type.nil?
    'active' if type == template.template_type
  end

  def render_store_standardized_work_build_previews_button(work)
    return if work.build_previews
    url = store_backend_standardized_work_path(work, standardized_work: { build_previews: true })
    options = { class: 'btn btn-default btn-small', remote: true, method: :patch }
    link_to t('shared.form_actions.build_previews'), url, options
  end

  def render_store_standardized_work_build_print_image_button(work)
    return if work.is_build_print_image
    url = store_backend_standardized_work_path(work, standardized_work: { is_build_print_image: true })
    options = { class: 'btn btn-default btn-small', remote: true, method: :patch }
    link_to t('shared.form_actions.build_print_image'), url, options
  end

  def render_store_standardized_state_button(work)
    case work.aasm_state
    when 'draft', 'pulled'
      render_publish_store_standardized_button(work)
    when 'published'
      render_pull_store_standardized_button(work)
    end
  end

  def render_publish_store_standardized_button(work)
    url = publish_store_backend_standardized_work_path(work)
    options = { class: 'btn btn-default btn-small', remote: true, method: :patch }
    link_to t('shared.form_actions.go_publish'), url, options
  end

  def render_pull_store_standardized_button(work)
    url = pull_store_backend_standardized_work_path(work)
    options = { class: 'btn btn-danger btn-small', remote: true, method: :patch }
    link_to t('shared.form_actions.go_pull'), url, options
  end

  def render_image_or_pdf(url)
    if url =~ /\.pdf/
      link_to '下載檔案', url, target: '_blank'
    else
      display_image_by_url(url)
    end
  end

  def display_image_by_url(url, blank_message: '(還未產生)', lazy: true)
    if url.blank?
      blank_message
    else
      lazy_class = lazy ? 'lazy' : ''
      img = image_tag(url, class: "#{lazy_class} work_thumb_image dashed-border", lazy: lazy)
      link_to img, url, target: '_blank', class: 'popup-image'
    end
  end

  def render_store_template_placeholder_image_url(template)
    template.sample_placeholder_image_url || get_model_image_url(template.product)
  end

  def render_store_tap_name(name, default_name)
    name.present? ? name : default_name
  end
end
