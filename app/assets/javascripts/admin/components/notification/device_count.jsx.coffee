# @cjsx

@CPA.Notification.DeviceCount = React.createClass

  getInitialState: ->
    decvices: 0

  componentWillReceiveProps: (nextProps) ->
    @queryCount(nextProps)

  render: ->
    <div className="infobox infobox-blue infobox-dark noti-infobox-fixed">
      This will be sent to approximately <span>{@state.decvices}</span> decvices.
    </div>

  queryCount: (nextProps) ->
    $.ajax
      type: 'GET'
      url: '/admin/devices/count'
      data:
        q:
          device_type_eq: nextProps.device
          country_code_in: _(nextProps.country).toString()
      dataType: 'json'
      success: (response) =>
        @setState(decvices: response.device_count)
      error: (response) ->
        console.log 'Device counting error!!', response