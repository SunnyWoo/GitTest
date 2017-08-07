#= require plugins/nprogress


NProgress.configure
  speed: 300
  minimum: 0.3
  ease: 'ease'
  showSpinner: true

$(document).on 'page:fetch', ->
  NProgress.start()
$(document).on 'page:restore', ->
  NProgress.remove()
$(document).on 'page:change',  ->
  NProgress.done()