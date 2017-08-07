$(document).on 'page:change', ->
  $currentPage = $('body.stores_controller.show_action')
  return if $currentPage.length == 0

  setupSendImpressingToGA = (visibleElems) ->
    triggerImpression = ->
      visibleElems
        .filter(':not([is-triggered-impression])')
        .filter(':in-viewport:visible')
        .ecProductImpressionByScroll()
        .attr('is-triggered-impression', true)

    $(document).off 'scroll', triggerImpression

    triggerImpression()
    $(document).on 'scroll', triggerImpression

  $currentPage.on 'click', '[data-product]', ->
    $(this).ecProductClick()

  # 使 kv 輪播影像的長寬比固定，目前是使用 Mobile Campaign 的 KV 長寬比
  $('[data-widget-slick]').each ->
    width = $(this).width()
    targetHeight = width * (600 / 1242)
    $(this).height(targetHeight)
    $(this).find('img').height(targetHeight)

    if $(this).find('img').length > 0
      $(this).not('.slick-initialized').slick dots: true, arrows: false, autoplay: true, autoplaySpeed: 2000

  $('[data-widget=tab]').each ->
    selected = $(this).data('selected')
    options = $(this).find('[data-widget=tab-option]')
    pages = $(this).find('[data-widget=tab-page]')

    showPageByHash = ->
      pages.hide()
      options.removeClass('is-active')

      currentTargetID = location.hash || "##{selected}"
      currentPage = $(currentTargetID)

      if currentPage.length > 0
        options.filter("[href=#{currentTargetID}]").addClass('is-active')
        currentPage.show()
      else
        target = pages.first()
        options.filter("[href=##{target.attr('id')}]").addClass('is-active')
        target.show()

    showPageByHash()

    $(window).on 'hashchange', (event) ->
      showPageByHash()
      $(window).trigger("lookup") # 切換 tab 時，讀取 viewport 以內的圖片

  $('[data-widget-filtering-and-sorting]').each ->
    new FilterAndSorting $(this), { afterRearrange: setupSendImpressingToGA }

  share = new SocialShare()

  $('#facebookBtn').click ->
    share.share('facebook')

  $('#twitterBtn').click ->
    share.share('twitter')

  $('#lineBtn').click ->
    share.share('line')

  $('#qqBtn').click ->
    share.share('qq')

  $('#weiboBtn').click ->
    share.share('weibo')

  $('#wechatBtn').click ->
    share.share('wechat')

  # 針對產品圖片，使用 lazy loading 增加使用者經驗
  $('img[data-src]').unveil(0, ->
    $(this).load( ->
      $(this).removeClass('isNotLoaded')
    )
  )

  # 切換 filter 時，讀取 viewport 以內的圖片
  $('[data-widget="filter-category"]').on('click', '[data-filter]', ->
    $(window).trigger("lookup")
  )
