$(document).on 'ready page:load', ->
  
  url = $('#work_name').data('workPath')
  work_id = $('#drawing').data('workId')

  $('#work_name .work-name').editable(url,
    width: '180px'
    height: '41px'
    name: 'work[name]'
    cssclass: 'edit-able'
    # onblur: 'ignore'
    submitdata: (value, settings) ->
      _method: 'PATCH'
    callback: (value, settings) ->
      json = JSON.parse(value)
      $(this).html(json.work.name)
      $('#drawing').attr('data-work-name', json.work.name)
      return
    submit: '<button type="submit"><span class="edittools-check"></span></button>'
  )

  $('.edittools-img_icon_backtoedit_normal').on 'click', ->
    $('#work_name .work-name').trigger('click')
    return

  return