$(document).on 'ready page:load', ->
  hidePrev = ->
    $this = $(this)
    $this.prev().find('img.line').css('opacity', 0) if $this.prev()
  showPrev = ->
    $this = $(this)
    $this.prev().find('img.line').css('opacity', 1) if $this.prev()
  $('ul.happysummer-nav li').hover(hidePrev, showPrev)

  $('a.select_material').on 'click', ->
    campaign = $('#campaing_inof').data('key')
    $this = $(this)
    key = $this.data('key')
    $('#material_span').text($this.text())
    $('#material_span').data('key', key)
    if key == 'mugs'
      $('[data-material=beach]:first').parents('.grid_2').hide()
    else
      $('[data-material=beach]:first').parents('.grid_2').show()
    ga 'send', 'event', "Campaign - #{campaign} - Web", 'select_material', key
    false;

  $('.material_download').on 'click', ->
    campaign = $('#campaing_inof').data('key')
    material = $(this).data('material')
    key = $('#material_span').data('key')
    platform = $(this).data('platform')
    default_url = "https://d2i5hifyddc647.cloudfront.net/campaign/2015/#{campaign.toLowerCase()}/material/#{key}/#{material}.jpg"
    url = $(this).data('url') or default_url
    ga 'send', 'event', "Campaign - #{campaign} - #{platform}", 'download_material', "#{key}_#{material}"
    if navigator.userAgent.match(/android/i)
      window.open(url);
    else
      $(this).attr('href', url)

  $('select.select_material').on 'change', ->
    campaign = $('#campaing_inof').data('key')
    $this = $(this).find(':selected')
    $('#material_span').data('key', this.value)
    $('#material_span').data('category_key', $this.data('category-key'))
    $(obj).data('deeplink', "create?category=#{$this.data('category-key')}") for obj in $('.summer_create')
    ga 'send', 'event', "Campaign - #{campaign} - Mobile", 'select_material', this.value

  $('.material-page-button').on 'click', ->
    if $('.material.hide').length > 0
      $(material).removeClass('hide') for material in $(".material.hide:lt(3)")
      $('.material-page-button').hide() if $('.material.hide').length == 0
