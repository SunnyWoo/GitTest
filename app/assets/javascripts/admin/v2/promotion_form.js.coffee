$ ->
  DOM_SELECTOR = '[data-role=promotion-form]'

  return if $(DOM_SELECTOR).length == 0

  class PromotionFormForItemablePrice
    constructor: (dom) ->
      @dom = dom
      @references = dom.find('[data-container=references]')
      @candidates = dom.find('[data-container=candidates]')
      @referencesBox = @references.closest('.widget-box')
      do @setUI
      do @bindEvents
      do @inactiveAddButtons
    setUI: ->
      @references.height($(window).height() - 250)
      @referencesBox.width(@referencesBox.width())
    bindEvents: ->
      @dom.on 'click', 'a[data-action=add]', (e) => @addPromotable(e)
      @dom.on 'click', 'a[data-action=remove]', (e) => @removePromotable(e)
      @dom.on 'click', 'a[data-action=bulk]', (e) => @bulkAddPromotable(e)

      $wrap = @references.closest('.promotion-container')
      $(window).on "scroll", (e) ->
        if $(this).scrollTop() > 147
          $wrap.addClass("promotion-container-fixed")
        else
          $wrap.removeClass("promotion-container-fixed")

    addPromotable: (e) ->
      $btn = $(e.currentTarget)
      gid = $btn.data('gid')

      if $btn.hasClass('disabled')
        return e.preventDefault()

      $refs = @references.find("[data-gid=#{gid}]")
      if $refs.length > 0
        if $refs.is(':visible')
          alert('Had been included')
          return e.preventDefault()

      @disableCandidate($btn)
      @dom.find('[type=submit]').prop('disabled', false)

    removePromotable: (e) ->
      e.preventDefault()
      $btn = $(e.currentTarget)
      gid = $btn.data('gid')
      $field = $btn.closest('[data-role=field]')
      destroy = $field.find('[data-role=destroy]')
      if destroy.length
        destroy.prop('disabled', false)
        $field.fadeOut()
      else
        $field.fadeOut -> $field.remove()

      $candidate = @candidates.find("a[data-gid=#{gid}")
      @enableCadidate($candidate) if $candidate.length

    bulkAddPromotable: (e) ->
      @candidates.find('.search-works-container tbody input:checked').not(':disabled').each (_, el) =>
        $(el).closest('tr').find('a[data-action=add]').trigger('click')

    inactiveAddButtons: ->
      @references.find('[data-gid]').each (_, e) =>
        gid = $(e).data('gid')
        $btn = @candidates.find("a[data-gid=#{gid}]")
        @disableCandidate($btn)

    disableCandidate: ($btn) ->
      $btn.addClass('disabled')

      if $btn.data('promotable') == 'product_category'
        $btn.closest('[data-role=product_category]').find('[data-role=product_model] a[data-gid]').addClass('disabled')

      if $btn.data('promotable') == 'standardized_work'
        $btn.parents('tr').find('input:checkbox').prop('disabled', true)
    enableCadidate: ($btn) ->
      $btn.removeClass('disabled')

      if $btn.data('promotable') == 'product_category'
        $pms = $btn.closest('[data-role=product_category]').find('[data-role=product_model] a[data-gid]')
        $pms.each (_, pm) =>
          gid = $(pm).data('gid')
          if @references.find("[data-gid=#{gid}]").length == 0
            $(pm).removeClass('disabled')

    appendReference: (html) ->
      @references.append(html);
      @references.animate
        scrollTop: @references.prop('scrollHeight')

  class PromotionFormForShippingFee
    constructor: (dom) ->
      @dom = dom

      @modelSchema = {}
      @modelSchema['designer'] = { root: 'designers', key: 'id', label: 'display_name' }
      @modelSchema['category'] = { root: 'product_categories', key: 'id', label: 'name' }
      @modelSchema['work'] = { root: 'works', key: 'gid', label: 'name' }
      @modelSchema['bdevent'] = { root: 'bdevents', key: 'id', label: 'title' }

      @dom.find('select.select2').select2()

      do @bindEvents
      do @toggleCondition
    bindEvents: ->
      @dom.on 'change', 'select[data-role=condition]', (e) => @toggleCondition(e)
      @dom.on 'select.onShown', 'select[data-source]', (e) => @fetchOptions(e)

    toggleCondition: (e) ->
      condition = @dom.find('select[data-role=condition]').val()
      condition = $(e.currentTarget).val() if e

      @dom.find("[data-condition]").hide().find('select').prop('disabled', true)

      conditions = [condition]
      conditions = ['include_product_models', 'include_designers'] if condition == 'include_designers_models'

      for cond in conditions
        @dom.find("[data-condition=#{cond}]").show().find('select').prop('disabled', false).trigger('select.onShown')

      if condition.match(/product|work|designer/)
        @dom.find("[data-condition=item]").show().find('select').prop('disabled', false)
      else
        @dom.find("[data-condition=item]").hide().find('select').prop('disabled', true)

    fetchOptions: (e) ->
      $select = $(e.currentTarget)
      model = $select.data('model')
      return if $select.find('option').length > 1

      url = $select.data('source')
      $.get url, (data) =>
        @buildOptions($select, data, model)
      , 'json'

    buildOptions: ($selector, data, model) ->
      selected = "#{$selector.data('selected')}".split(',')

      if model == 'product' # grouped option
        for category in data.categories
          group = $("<optgroup label='#{category.name}' />")
          for entry in category.models
            option = $("<option value='#{entry.id}'>#{entry.name}</option>")
            option.prop('selected', true) if selected.indexOf("#{entry.id}") != -1
            group.append option
          $selector.append(group)
      else
        schema = @modelSchema[model]
        entries = data[schema.root]
        for entry in entries
          value = entry[schema.key]
          name = entry[schema.label]
          option = $("<option value='#{value}'>#{name}</option>")
          option.prop('selected', true) if selected.indexOf("#{value}") != -1
          $selector.append option

      $selector.trigger('change.select2')

  class PromotionFormWithSimpleDiscount
    constructor: (dom) ->
      @dom = dom
      do @bindEvents
      do @toggleRuleOption
      @dom.find('select.select2').select2()
    bindEvents: ->
      @dom.on 'change', '#promotion_rule_parameters_discount_type', (e) => @toggleRuleOption()
    toggleRuleOption: ->
      discountType = $('#promotion_rule_parameters_discount_type').val()
      @dom.find('[data-toggle=discount_type]').hide()
      @dom.find("[data-#{discountType}]").show()


  $dom = $(DOM_SELECTOR)

  #### Shared Behaviors

  toggleEndsAt = ->
    isUnlimited = $('[data-input=unlimited]').prop('checked')
    $dom.find('[data-input=ends_at]').prop('disabled', isUnlimited)

  $dom.on 'change', '[data-input=unlimited]', toggleEndsAt

  do toggleEndsAt

  switch $dom.data('type')
    when 'for_itemable_price'
      $.promotionForm = new PromotionFormForItemablePrice($dom)
    when 'for_shipping_fee'
      $.promotionForm = new PromotionFormForShippingFee($dom)
    when 'for_product_category', 'for_product_model'
      $.promotionForm = new PromotionFormWithSimpleDiscount($dom)
