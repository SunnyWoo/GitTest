jQuery ($) ->
  $(document).on 'ready page:load', ->
    $('.works.show .thumb-list > ul > li[data-thumb=1]').trigger('click')
    $('.archived_works.show .thumb-list > ul > li[data-thumb=1]').trigger('click')
