
$(document).on 'click', '.share_fb_feed_full', ->
  elm = $(this)
  FB.ui
    method: 'feed'
    link: elm.data('href') or location.href
    name: elm.data('name') or document.title
    picture: elm.data('picture')
    description: elm.data('description')

  return false

$(document).on 'click', '.__luckey_refresh', ->
  window.location.reload()
  $('html, body').animate({ scrollTop: $('.lucky2016-secret-panel').offset().top }, 500);

$(document).on 'click', '.lucky2016m-kv-go-info', ->
  campaignCheckUrl("#info")
  window.location.hash = "#info"
  $('.lucky2016m-bg').addClass('dark')

changeBg = (hash) ->
  if hash == '#info' or !hash
    $('.lucky2016m-bg').addClass('dark')
  else
    $('.lucky2016m-bg').removeClass('dark')

$(document).on 'ready page:load', ->
  changeBg(window.location.hash)

  $('select#m-campaign-select').on 'change', ->
    changeBg("##{$(this).val()}")

  $divine_form = $('.divine_form')
  $lucky_year  = $divine_form.find('.__lucky_year')
  $lucky_month = $divine_form.find('.__lucky_month')
  $lucky_date  = $divine_form.find('.__lucky_date')
  $lucky_hour = $divine_form.find('.__lucky_hour')
  $('.divine_cardd').hide()
  $('.lucky2016-divine-result').hide()
  $('.lucky2016-divine-result .__lucky_heart_title').hide()
  $('.lucky2016-divine-result .__lucky_heart').hide()
  $('.lucky2016-divine-article').hide()

  $('.lucky2016-divine-result .reading').on 'click touch', ->
    ga "send", "event", "lucky2016", "readmore"
    $('.lucky2016-divine-result .reading').hide()
    $('.lucky2016-divine-result .__lucky_heart_title').show()
    $('.lucky2016-divine-result .__lucky_heart').show()

  $divine_form.on 'click touch', '.dropdown-menu li', ->
    $self = $(this)
    value = $self.data('value')
    $self.parents('.dropdown').find('.val').html($self.text())
    $self.parents('.dropdown').data('dateValue', value).removeClass('lucky2016-show-alert')

  $divine_form.find('.__lucky_email').on 'change', ->
    $(this).parent(".divine_form_item").removeClass('lucky2016-show-alert')

  $divine_form.on 'click touch', '.__lucky_date', ->
    $self = $(this)
    year = $lucky_year.data 'dateValue'
    month = $lucky_month.data 'dateValue'
    if year? and month?
      $model_dropdown = $self.find('.dropdown-menu')
      date = new Date year, month, 0
      days = _.range 1, date.getDate() + 1
      li_arr = []
      _.each days, (num, i) ->
        li_arr[i] = $("<li data-value=#{num} />").text(num + ' 日').prop('outerHTML')
      $model_dropdown[0].innerHTML = li_arr.join('')

  divineResult = (divineObj) ->
    info = divineObj.info
    message = divineObj.message
    advantage = divineObj.advantage
    disadvantage= divineObj.disadvantage
    heart = divineObj.heart
    articles_img_urls = divineObj.articles_img_urls
    articles = divineObj.articles
    $('.__lucky_fortune').html(message.join('<br />'))
    $('.__lucky_advantage').text(advantage)
    $('.__lucky_shortcoming').text(disadvantage)
    $('.divine_form').fadeOut 1000, ->
      $('.__lucky_card').on 'load', ->
      $('.divine_cardd').fadeIn 1000, ->
        $('.lucky2016-divine-result').slideDown()
        $('.lucky2016-divine-article').slideDown()
    $('.__lucky_card').attr "src", divineObj.card
    $('.__lucky_heart').text(heart)
    $('.__luckey_name_adv').text(info.advantage_title)
    $('.__luckey_name_disadv').text(info.disadvantage_title)
    $('.__luckey_name_upgrade').text(info.heart_title)

    _.forEach articles, (v, k) ->
      $layer = $(".__lucky_aticle_#{k}")
      $layer.find('img').attr 'src', v.img
      $layer.find('.article_layer_title').text(v.title)
      $layer.find('.article_layer_link').attr 'href', v.link

  divine = (year, month, day, hour) ->
    zwds = new Zwds()
    chart = zwds.getChart(+year, +month, +day, +hour)
    stars1 = chart.getSelfStars()
    stars2 = chart.getTravelStars()
    loc = chart.selfHouse
    info = new ZwdsInfo()
    info = info.getInfo(stars1, loc, stars2)
    advantage = info.advantage
    disadvantage = info.disadvantage
    articles = info.article or []
    divineObj = {
      info: info,
      message: info.msg,
      advantage: advantage,
      disadvantage: disadvantage,
      heart: info.heart,
      card: info.images,
      articles_img_urls: articles,
      articles: articles
    }
    divineResult(divineObj)
    $('html, body').animate({ scrollTop: $('.lucky2016-secret-panel').offset().top }, 500);

  showAlert = (selector) ->
    elm = $(selector)
    elm.addClass('lucky2016-show-alert')

  $('#lucky_divine').on 'click touch', ->
    year = $lucky_year.data 'dateValue'
    month = $lucky_month.data 'dateValue'
    date = $lucky_date.data 'dateValue'
    hour = $lucky_hour.data 'dateValue'
    email = $('.__lucky_email').val()
    if year? and month? and date? and hour? and email
      ga "send", "event", "lucky2016", "click", "#{email},#{year},#{month},#{date},#{hour}"
      divine(year, month, date, hour)

      $('.lucky2016-card-icon').hide()
      $('.lucky2016_mobile_title3').hide()
      $('.lucky2016-divine-article .item').hover(
        ->
          $(@).find('.article_layer').stop(true, true).animate({'opacity': '0.8'})
        ,
        ->
          $(@).find('.article_layer').stop(true, true).animate({'opacity': '0'})
      )
    else
      showAlert('.__lucky_year') unless year?
      showAlert('.__lucky_month') unless month?
      showAlert('.__lucky_date') unless date?
      showAlert('.__lucky_hour') unless hour?
      showAlert($('.__lucky_email').parent(".divine_form_item")) unless email
