@MobileComponentFieldset =
  check: (selector, val) ->
    selector.find('.form-group').addClass('hide')
    selector.find('img[id*=image_desc]').addClass('hide')
    selector.find("img#image_desc_#{val}").removeClass('hide') if selector.find("img#image_desc_#{val}").length > 0

    switch val
      when 'kv'
        selector.find('[class~=image]').not(':first').removeClass('hide')
        selector.find('[class~=action_type], [class~=action_target], [class~=action_key]').removeClass('hide')
      when 'ticker'
        selector.find('[class~=title]:first').removeClass('hide')
        selector.find('[class~=content]').removeClass('hide')
      when 'product_line'
        selector.find('[class~=content]').removeClass('hide')
      when 'campaign_section'
        selector.find('[class~=section_title]:first, [class~=section_color]:first').removeClass('hide')
        selector.find('[class~=desc_short], [class~=action_text]').removeClass('hide')
        selector.find('[class~=campaign_id]').removeClass('hide')
        selector.find('[class~=title]').not(':first').removeClass('hide')
        selector.find('[class~=image]').not(':first').removeClass('hide')
      when 'products_section'
        selector.find('[class~=section_title]:first, [class~=section_color]:first').removeClass('hide')
        product_filter_value = selector.find('[class~=product_filter]:first select').val() + '_id'
        selector.find('[class~='+product_filter_value+']:first').removeClass('hide').find('select').select2()
        selector.find('[class~=product_type]:first').removeClass('hide')
        selector.find('[class~=product_filter]:first').removeClass('hide')
        selector.find('[class~=work_uuid], [class~=desc_short]').removeClass('hide')
        selector.find('[class~=will_sale_text], [class~=on_sale_text], [class~=tip_text]').removeClass('hide')
        selector.find('[class~=title]').not(':first').removeClass('hide')
        selector.find('[class~=image]').removeClass('hide')
        selector.find('[class~=product_id]').removeClass('hide').find('input').attr('disabled', 'disabled')
        WorkSearchSelect2.init(selector.find('[class~=work_uuid] select'))
        selector.find('[class~=action_type], [class~=action_target], [class~=action_key]').removeClass('hide')
        # todo 可以選擇 designer id, 只能選 type b
      when 'tab_section'
        selector.find('[class~=create_text], [class~=shop_text], [class~=download_text]').removeClass('hide')
      when 'media_section'
        selector.find('[class~=media_type], [class~=tab_category]').removeClass('hide')
        selector.find('[class~=content], [class~=media_url], [class~=action_text]').removeClass('hide')
        selector.find('[class~=title]').not(':first').removeClass('hide')
        selector.find('[class~=image]').not(':first').removeClass('hide')
        selector.find('[class~=action_type], [class~=action_target], [class~=action_key]').removeClass('hide')
      when 'create_section'
        selector.find('[class~=image], [class~=product_category_key], [class~=product_model_key]').removeClass('hide')
        selector.find('[class~=title]').removeClass('hide')
      when 'description_section'
        selector.find('[class~=description]').removeClass('hide')
        selector.find('[class~=title]').not(':first').removeClass('hide')
      when 'download_section'
        selector.find('[class~=product_category_key], [class~=product_model_key], [class~=download_url]').removeClass('hide')
        selector.find('[class~=title], [class~=image]').removeClass('hide')
      when 'campaign_background'
        selector.find('[class~=image]:first').removeClass('hide').find('label').text('Background')

  pageReload: ->
    $('.mobile_components_block').each () ->
      MobileComponentFieldset.check($(this), $(this).find('select[name*=key]').val())

$(document).on 'page:change',  ->
  MobileComponentFieldset.pageReload()

  $('.mobile_components_list').disableSelection()

  $('.sub_components_block').sortable
    handle: '.move'
    update: (e, ui) ->
      ui.item.parent().find('input[name*=position]').each (index) ->
        $(this).val(index + 1)
  $('.sub_components_block').disableSelection()

  $(document).on 'change', 'select.mobile_component_key', ->
    MobileComponentFieldset.check($(this).parents('.mobile_components_block'), $(this).val())

  $(document).on 'change', '.mobile_components_block .product_filter select', ->
    selector = $(this).parent('.product_filter')
    product_filter_option = selector.nextAll('.product_filter_option')
    product_filter_option.find('select').val('').change()
    product_filter_option.addClass('hide')
    if ['designer', 'tag', 'collection'].includes($(this).val())
      obj = selector.nextAll(".product_filter_option.#{$(this).val()}_id")
      obj.removeClass('hide')
      if obj.find('.select2').size() == 0
        obj.find('select').select2()

$(document).on 'click', 'a.add_sub_components', ->
  $this = $(this)
  $this.attr('disable', 'disable')
  $this.parent().find('.add_nested_fields_link').click()
  mobile_components_block = $this.parents('.mobile_components_block')
  MobileComponentFieldset.check(mobile_components_block, mobile_components_block.find('select[name*=key]').val())
  $this.removeAttr('disable')

$(document).on 'click', 'a.mobile_page_preview', ->
  $.ajax
    type: 'put'
    url: $(this).data('url')
    data:
      $(this).parent('form').serialize()
    success: (data) ->
      $('#preview_tab').removeClass('hide');
      $('#preview_tab .active a').click()

$(document).on 'click', 'a.preview_device', ->
  $.ajax
    type: 'get'
    url: $(this).data('url')
    data:
      device: $(this).data('device')
      width: $(this).data('width')
      height: $(this).data('height')
