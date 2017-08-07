function sliceLocaleFromUrl() {
  var locale
  var matchedLocale = location.pathname.match(/^\/((zh\-TW)|(zh\-CN)|(en))/)

  if (matchedLocale) {
    locale = matchedLocale[1]
  } else {
    locale = 'zh-TW'
  }

  return locale
}

function isInFacebookIOSApp() {
  if (!navigator) return false

  if (/FBIOS/.test(navigator.userAgent)) {
    return true
  } else {
    return false
  }
}
