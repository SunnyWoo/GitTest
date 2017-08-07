$(document).on 'page:change', ->
  operateStoreComponentFieldset = ->
      $('.nested_store_components').delegate '.store_layout_key', 'change', ->
        $target = $(this)
        $content = $target.parent().siblings('.store_layout_content').children('textarea')
        $image = $target.parent().siblings('.store_layout_image').children('input')
        if $target.val() in ['kv']
          $image.parent().removeClass('hide')
          $content.val('')
          $content.parent().addClass('hide')
          if $target.val() == 'kv' then $target.after('<p>長寬大小限制: 1242x600</p>')
        else
          $content.parent().removeClass('hide')
          $image.val('')
          $image.parent().addClass('hide')

  do operateStoreComponentFieldset

  $(document).on "fields_added.nested_form_fields", operateStoreComponentFieldset
