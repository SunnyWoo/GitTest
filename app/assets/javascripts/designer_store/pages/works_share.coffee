$(document).on 'page:change', ->
  return if $('body.works_controller.share_action').length == 0

  $('[data-widget-slick]').not('.slick-initialized').slick dots: true, arrows: false

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

  $('[data-share-button]').each ->
    $(this).on 'click', (event) ->
      $.ajax
        url: $(this).data('submit-url')
        type: 'patch'
        data:
          work:
            share_text: $('[data-share-content]').val()
        complete: ->
          share.update description: $('[data-share-content]').val()
          $('#wexin-mask').show()
          $('#share-mask').show()
