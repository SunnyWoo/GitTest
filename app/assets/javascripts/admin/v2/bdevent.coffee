jQuery ($) ->
  $(document).on 'page:change',  ->
    $('form.new_bdevent fieldset .remove').parent().remove()
    $('form.edit_bdevent fieldset .remove').parent().remove()

    $('.add_nested_fields_link[data-object-class=bdevent_image]').on 'click', () ->
      $this = $(this)
      setTimeout ->
        $insert_into = $this.data('insert-into')
        tmp = $("##{$insert_into} fieldset:last")
        tmp.find('input[name*=locale]').val($insert_into.replace('_images',''))
        tmp.find('input[name*=bdevent_id]').val($this.data('bdevent-id'))
      , 200

    $('form.new_bdevent, form.edit_bdevent').validate
      errorElement: 'span'
      errorPlacement: (lable, element) =>
        $(element).parent().addClass('has-error').append(lable)
        return

    $('#redeem_type').on 'change', () ->
      $this = $(this)
      if $this.val() == '0'
        $('#bdevent_bdevent_redeem_attributes_quantity').val(1)
        $('#bdevent_bdevent_redeem_attributes_quantity').attr('readonly', true)
        $('#redeem_usage_count_limit').show()
        usage_count_limit(1, false) if !!!$('#no_limit:checked').length
      else
        $('#bdevent_bdevent_redeem_attributes_quantity').removeAttr('readonly')

    usage_count_limit = (val, readonly = true) ->
      $column = $('#bdevent_bdevent_redeem_attributes_usage_count_limit')
      $column.val(val).attr('readonly', readonly)

    $('#no_limit').on 'change', () ->
      if $(this).attr('checked') == 'checked'
        usage_count_limit(-1, true)
      else
        usage_count_limit(1, false)

    $('#bdevent_bdevent_redeem_attributes_quantity').on 'change', () ->
      if parseInt($(this).val()) == 1
        $('#redeem_usage_count_limit').show()
        usage_count_limit(1, false) if !!!$('#no_limit:checked').length
      else
        $('#redeem_usage_count_limit').hide()
        usage_count_limit(1, true)

    $('.target_bdevent_redeem').on 'click', () ->
      $this = $(this)
      $target = $(".bdevent_redeems[data-id=#{$this.data('id')}]")
      if $this.text() == 'show'
        $this.text('hide')
        $target.removeClass('hide')
      else
        $this.text('show')
        $target.addClass('hide')
      return false

    $('#bdevent_flex_select').on 'change', () ->
      $this = $(this)
      $.ajax
        type: 'PATCH'
        url: $this.data('url')
        data:
          flex: $this.val()
      .done (e) ->
        if e.status == 'ok'
          Gritter.regular_msg e.message
        else
          Gritter.error_msg e.message

