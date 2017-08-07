jQuery ($) ->
  $(document).on 'ready page:load', ->
    $('.tag_select2').select2
      tags: true
    .on 'change', ->
      formatTagSelectText()

    formatTagSelectText()


    if $('#update_type')
      $('.change-tag').click ->
        $('#update_type').val($(this).data().type)
        $('#change_tags').modal('show')

formatTagSelectText = ->
  $input = $('.tag_select2').next('span.select2').find('input.select2-search__field')
  $input.on 'keyup keydown change ', ->
    if new RegExp(/[^a-zA-Z0-9_-]+/g).test($(this).val())
      text = $(this).val().replace(/[^a-zA-Z0-9_-]+/g,'')
      $(this).val(text)
      return
