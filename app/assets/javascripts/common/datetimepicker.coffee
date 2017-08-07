#http://xdsoft.net/jqplugins/datetimepicker/
#= require plugins/moment
#= require plugins/date-time/jquery.datetimepicker.full.min

Date.parseDate = (input, format) ->
  moment(input, format).toDate()

Date::dateFormat = (format) ->
  moment(this).format format

jQuery ($) ->
  $(document).on 'ready page:load', ->
    jQuery.datetimepicker.setLocale('zh');
    $('.datetimepicker').datetimepicker
      format: 'YYYY-MM-DD H:mm'
      formatTime: 'H:mm'
      formatDate: 'YYYY-MM-DD'

    $('.batch_deadline_picker').datetimepicker
      format: 'YYYY-MM-DD H:mm'
      formatTime: 'H:mm'
      formatDate: 'YYYY-MM-DD'

    $('#datetimepicker_start').datetimepicker
      format: 'YYYY-MM-DD H:mm'
      formatTime: 'H:mm'
      formatDate: 'YYYY-MM-DD'
      onShow: (ct) ->
        @setOptions maxDate: if $('#datetimepicker_end').val() then $('#datetimepicker_end').val() else false
        return
      timepicker: true

    $('#datetimepicker_end').datetimepicker
      format: 'YYYY-MM-DD H:mm'
      formatTime: 'H:mm'
      formatDate: 'YYYY-MM-DD'
      onShow: (ct) ->
        @setOptions minDate: if $('#datetimepicker_start').val() then $('#datetimepicker_start').val() else false
        return
      timepicker: true

    $('#q_created_at_gteq').datetimepicker
      format: 'YYYY-MM-DD H:mm'
      formatTime: 'H:mm'
      formatDate: 'YYYY-MM-DD'
      onShow: (ct) ->
        @setOptions minDate: if $('#q_created_at_lteq').val() then setValidateTime($('#q_created_at_lteq').val(), -1) else false
        return

    $('#q_created_at_lteq').datetimepicker
      format: 'YYYY-MM-DD H:mm'
      formatTime: 'H:mm'
      formatDate: 'YYYY-MM-DD'
      onShow: (ct) ->
        @setOptions maxDate: if $('#q_created_at_gteq').val() then setValidateTime($('#q_created_at_gteq').val(), 1) else false
        return

    $('.date_gteq').datetimepicker
      format: 'YYYY-MM-DD'
      formatDate: 'YYYY-MM-DD'
      timepicker:false

    $('.date_lteq').datetimepicker
      format: 'YYYY-MM-DD'
      formatDate: 'YYYY-MM-DD'
      timepicker:false

    setValidateTime = (time, range) ->
      time = new Date(time)
      range = range * 60 * 24 * 60 * 60 * 1000
      validateTime = time.getTime() + range
      return moment(new Date(validateTime)).format('YYYY-MM-DD HH:mm')

    return
