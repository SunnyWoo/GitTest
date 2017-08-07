@WorkSearchSelect2 =
  init: (selector) ->
    formatWorkResult = (repo) ->
      if repo.loading
        return repo.text
      if repo.name
        markup = "<div class='clearfix'>
                    <div class='col-sm-6'>
                      <img src='#{repo.remote_order_image_url}' style='max-width: 90%' />
                    </div>
                    <div clas='col-sm-6'>
                      <div class='clearfix'>
                        <div class='col-sm-6'>ID: #{repo.work_id}</div>
                        <div class='col-sm-6'>UUID: #{repo.uuid}</div>
                        <div class='col-sm-6'>Modle: #{repo.model}</div>
                        <div class='col-sm-6'>Nmae: #{repo.name}</div>
                        <div class='col-sm-6'>UserDisplayName: #{repo.user_display_name}</div>
                      </div>
                    </div>
                  </div>"

    after_select = (repo)->
      $widget_main = $("select [value=#{repo.uuid}]").parents('.widget-main')
      if $widget_main? && repo?
        setDefaultValue = (input, defaultValue) ->
          $input = $widget_main.find(input)
          $input.val(defaultValue) if $input.val() == ''
        setDefaultValue('.title input', repo.name)
        setDefaultValue('.desc_short input', repo.model)
        setDefaultValue('.will_sale_text input', '即將開賣')
        setDefaultValue('.on_sale_text input', '馬上搶')

    formatWorkSelection = (repo) ->
      if repo.work_id > 0
        after_select(repo)
        "#{repo.work_id} - #{repo.name} - #{repo.model}"
      else
        repo.text

    selector.select2
      tags: true
      ajax:
        url: '/admin/standardized_works/search'
        dataType: 'json'
        delay: 250
        cache: true
        data: (params) ->
          q: params.term
          page: params.page
        processResults: (data, page) ->
          { results: data.standardized_works }
      escapeMarkup: (markup) ->
        markup
      minimumInputLength: 1
      templateResult: formatWorkResult
      templateSelection: formatWorkSelection

@RedeemWorkSearchSelect2 =
  init: (selector) ->
    formatWorkResult = (repo) ->
      if repo.loading
        return repo.text
      if repo.name
        markup = "<div class='clearfix'>
                    <div class='col-sm-6'>
                      <img src='#{repo.remote_order_image_url}' style='max-width: 90%' />
                    </div>
                    <div clas='col-sm-6'>
                      <div class='clearfix'>
                        <div class='col-sm-6'>ID: #{repo.id}</div>
                        <div class='col-sm-6'>Modle: #{repo.model}</div>
                        <div class='col-sm-6'>Nmae: #{repo.name}</div>
                        <div class='col-sm-6'>UserDisplayName: #{repo.user_display_name}</div>
                      </div>
                    </div>
                  </div>"

    formatWorkSelection = (repo) ->
      return repo.id + ' - ' + repo.text

    selector.select2
      tags: true
      ajax:
        url: '/admin/works/search'
        dataType: 'json'
        delay: 250
        data: (params) ->
          q: params.term
          page: params.page
          redeem: true
        processResults: (data, page) ->
          { results: data.works }
        cache: true
      escapeMarkup: (markup) ->
        markup
      dropdownAutoWidth: true
      minimumInputLength: 1
      templateResult: formatWorkResult
      templateSelection: formatWorkSelection

$(document).on 'ready page:load', ->
  $('#newsletter_filter').select2
    placeholder: "Select a Mailing list"
    tags: true

  if $('#bdevent_bdevent_redeem_attributes_product_model_ids').length > 0
    $this = $('#bdevent_bdevent_redeem_attributes_product_model_ids')

    $this.select2
      tags: true

    if $this.data('bdevent-id')?
      $this.prop('disabled', true);

  RedeemWorkSearchSelect2.init($('.bdevent_works_select'))

  $('.add_nested_bdevent_products').on 'click', ->
    setTimeout () ->
      RedeemWorkSearchSelect2.init($('.bdevent_works_select'))
    , 500
