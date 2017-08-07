jQuery ($) ->
  $(document).on 'ready page:load', ->
    CPA.Base.showLoading = true

    # checkbox check all
    $(document).on 'click', 'table th input:checkbox', () ->
      that = this
      $(this).closest('table').find('tr > td:first-child input:checkbox')
      .each ()->
        this.checked = that.checked;
        $(this).closest('tr').toggleClass('selected');

    $(document).on 'submit', 'form', ->
      submit_btn = $(this).find('[type=submit]')
      submit_btn.attr("disabled","disabled")
      $.fancybox.showLoading()

    $( document ).ajaxSend (e, request, settings) ->
      if CPA.Base.showLoading and showLoadingForUrl(settings.url)
        $.fancybox.showLoading()

    $( document ).ajaxStop ->
      $.fancybox.hideLoading()

    priceTierInfo = ->
      $el = $(@)
      if $el.data('load')
        return $el.data('load')
      id = $(@).data('price-tier')
      data = null

      $.ajax "/admin/price_tiers/#{id}",
        async: false
        success: (res) ->
          data = res
      $el.data('load', data)
      data

    $('[data-price-tier]').tooltip
      title: priceTierInfo
      html: true
      container: 'body'

  showLoadingForUrl = (url) ->
    url.indexOf(CPA.path('/jobs')) isnt 0
