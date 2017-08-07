templates =
  qq: 'http://connect.qq.com/widget/shareqq/index.html?url={{URL}}&title={{TITLE}}&source={{SOURCE}}&desc={{DESCRIPTION}}&pics={{IMAGE}}'
  weibo: 'http://service.weibo.com/share/share.php?url={{URL}}&title={{TITLE}}&pic={{IMAGE}}&appkey={{WEIBOKEY}}'
  wechat: 'javascript:'
  facebook: 'https://www.facebook.com/sharer/sharer.php?u={{URL}}'
  twitter: 'https://twitter.com/intent/tweet?text={{TITLE}}&url={{URL}}&via={{ORIGIN}}'
  line: 'http://line.me/R/msg/text/?{{DESCRIPTION}} {{URL}}'

class SocialShare
  constructor: (options = {}) ->
    @defaultOptions =
      title: @_getMetaContentByName('title') || @_getMetaContentByName('Title') || document.title
      description: @_getMetaContentByName('description') || @_getMetaContentByName('Description') || ''
      image: (document.images[0] || 0).src || ''
      url: location.href
      facebookQuote: @_getMetaContentByName('description') || @_getMetaContentByName('Description') || ''

    @options = options

  share: (platform) ->
    throw Error('Noooooo, platform not support') unless templates[platform]?
    shareOptions = @_getOptions()
    shareOptions.url = @_addPlatformTraceParams(shareOptions.url, platform)

    if platform == 'wechat'
      @_creatWechatQRCodeModal(shareOptions)
    else
      window.open(@_makeUrl(platform, shareOptions))

  update: (options) ->
    Object.assign(@options, options)

  _getOptions: ->
    Object.assign({}, @defaultOptions, @options)

  _getMetaContentByName: (name) ->
    (document.getElementsByName(name)[0] || 0).content

  _makeUrl: (name, data) ->
    templates[name].replace(/\{\{(\w)(\w*)\}\}/g, (m, fix, key) ->
      nameKey = name + fix + key.toLowerCase()
      key = (fix + key).toLowerCase()
      url =
        if typeof data[nameKey] == 'undefined'
          data[key] || ''
        else
          data[nameKey] || ''

      encodeURIComponent(url)
    )

  _addPlatformTraceParams: (url, platform) ->
    return '' unless url

    if /\?/.test(url)
      url + '&_ref=' + platform
    else
      url + '?_ref=' + platform

  _creatWechatQRCodeModal: (data) ->
    $modal = $("
      <div id='wechat-qrcode-mask' class='mask' style='display: block; z-index: 999' data-trigger-hide='#wechat-qrcode-mask'>
        <div class='mask-content'>
          <div class='shareModal'>
            <strong>分享至微信</strong>
            <p style='line-height: 1.4;'>微信里点『发现』，扫一下二维码</br>便可将本文分享至朋友圈。</p>
            <div id='qrcode'></div>
            </br>
            <div class='shareModal-cancel' data-trigger-hide='#wechat-qrcode-mask'>取消</div>
          </div>
        </div>
      </div>
    ")
    $modal.appendTo('body')

    $qrcodeBlock = $modal.find('#qrcode')
    new QRCode($qrcodeBlock[0], {text: data.url, width: $qrcodeBlock.width(), height: $qrcodeBlock.width() });

window.SocialShare = SocialShare
