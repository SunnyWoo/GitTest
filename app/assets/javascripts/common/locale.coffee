window.getLocale = () ->
  locale = 'en'
  tmp = $('body').attr('class').match('locale-[a-zA-Z-]+')
  locale = tmp[0].replace('locale-','') if tmp.length > 0
  return locale
