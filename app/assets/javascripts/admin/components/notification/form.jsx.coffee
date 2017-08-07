# @cjsx

@CPA.Notification.Form = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getInitialState: ->
    deviceData: ""
    countryData: []
    pushOption: "now"
    deliveryTime: ""
    message: ""
    link: ""
    customLink: ""
    readOnly: false
    platform: {}
    country: {}
    deeplink: {}
    filter_count: 0

  componentWillMount: ->
    if @props.showUrl
      @setState(readOnly: true)
      @getReadOnlyData()

  componentDidMount: ->
    $(@refs.pushMessage.getDOMNode()).inputlimiter
      limit: 100
      remText: '%n character%s remaining...'
      limitText: 'max allowed : %n.'
    @getRecipients()

  getRecipients: ->
    request = $.ajax
      url: @props.apiUrl
      type: 'GET'
      dataType: 'json'
      success: (response) =>
        @setState
          platform: response.platform
          country: response.country
          deeplink: response.deeplink
      error: (response) =>
        console.log 'Get Recipients Error! >>', response

  getReadOnlyData: ->
    request = $.ajax
      url: @props.showUrl
      type: 'GET'
      dataType: 'json'
      success: (response) =>
        data = response.notification
        if data.filter?.country_code_in
          @setState(countryData: data.filter.country_code_in)
        if data.filter?.device_type_in
          @setState(deviceData: data.filter.device_type_in)
        @setState
          deliveryTime: data.delivery_at
          message:      data.message
          link:         data.deep_link
          filter_count: data.filter_count
      error: (response) =>
        console.log 'Get Recipients Error! >>', response

  getDateTimeNow: ->
    date = new Date()
    {
      mm: date.getMinutes()
      hh: date.getHours()
      dd: if date.getDate() < 10 then '0' + date.getDate() else date.getDate()
      MM: if date.getMonth() + 1 < 10 then '0' + (date.getMonth() + 1) else date.getMonth() + 1
      yy: date.getFullYear()
    }

  updatePlatform: (e) ->
    @setState(deviceData: e.target.value)

  updateCountry: (e, type) ->
    newData = @state.countryData or []
    if type is true
      newData.push e.target.value
    else
      newData = _.without newData, e.target.value
    @setState(countryData: newData)

  updatePushOption: (e) ->
    @setState(pushOption: e.target.value)
    if e.target.value is 'now'
      @setState(deliveryTime: "")

  updateDateTime: (dateTime) ->
    @setState(deliveryTime: dateTime)

  updateMessage: (e) ->
    @setState(message: e.target.value)

  updateDeeplink: (e) ->
    if e.value
      @setState(customLink: e.value)
    else
      @setState(link: e.target.value)

  renderLists: (type) ->
    lists = []
    notice = ""
    title = type.charAt(0).toUpperCase() + type.slice(1).toLowerCase()
    if type is 'platform'
      _.forEach @state.platform, (value, name) =>
        checked = if value.toString() is @state.deviceData then true else false
        lists.push <CPA.Notification.PlatformInput value={value.toString()}
                                                   text={name}
                                                   checked={checked}
                                                   disabled={@state.readOnly}
                                                   onClick={@updatePlatform} />
    else if type is 'country'
      notice = "(If you do not choose, the default country will be global.)"
      _.forEach @state.country, (value, name) =>
        checked = @state.countryData.includes(value)
        lists.push <CPA.Notification.CountryInput value={value}
                                                  text={name}
                                                  checked={checked}
                                                  disabled={@state.readOnly}
                                                  onChange={@updateCountry} />
    <div key={type}>
      <div className="form-inline">
        <div className="clearfix">
          <h4 className="pull-left">{title}</h4>
          <span className="pull-left noti-notice">{notice}</span>
        </div>
        {lists}
      </div>
    </div>

  renderDelivery: ->
    if @state.readOnly
      <div>
        <h4>Delivery on</h4>
        <h5>{new Date(@state.deliveryTime).toLocaleString()}</h5>
      </div>
    else
      <div>
        <CPA.Notification.DeliveryTypeInput option={@state.pushOption}
                                            onChange={@updatePushOption} />
        {@renderDeliveryTime()}
      </div>

  renderDeliveryTime: ->
    date = @getDateTimeNow()
    if @state.pushOption is 'later'
      dateNow = date.yy + '-' + date.MM + '-' + date.dd
      <CPA.Notification.DeliveryTimeInput value={dateNow}
                                          onChange={@updateDateTime} />

  renderMessageInput: ->
    if @state.readOnly
      <textarea ref="pushMessage"
                className="text optional form-control"
                cols="5"
                rows="5"
                value={@state.message}
                disabled=true ></textarea>
    else
      <textarea ref="pushMessage"
                className="text optional form-control"
                cols="5"
                rows="5"
                name="message"
                maxLength=100
                onBlur={@updateMessage} ></textarea>

  renderDeepLinks: ->
    links = []
    _.forEach @state.deeplink, (value, name) =>
      links.push { value: value, label: name }
    <CPA.Notification.DeeplinkInput value={@state.link}
                                    links={links}
                                    readOnly={@state.readOnly}
                                    onChange={@updateDeeplink} />

  renderBtn: ->
    if @state.readOnly
      <div className="text-right">
        <button className="btn btn-primary" onClick={@cancel}>Back</button>
      </div>
    else
      <div className="text-right">
        <button className="btn btn-link" onClick={@cancel}>Cancel</button>
        <button className="btn btn-primary" onClick={@save}>Save</button>
      </div>
  renderDeviceCount: ->
    if @state.readOnly
      <div className="infobox infobox-blue infobox-dark noti-infobox-fixed">
        This will be sent to approximately <span>{@state.filter_count}</span> decvices.
      </div>
    else
      <CPA.Notification.DeviceCount device={@state.deviceData} country={@state.countryData} filter_count={@state.filter_count} />

  cancel: ->
    Turbolinks.visit('/admin/notifications')

  save: ->
    filter = {}
    filter['device_type_in'] = @state.deviceData if @state.deviceData
    filter['country_code_in'] = @state.countryData if @state.countryData.length > 0

    data =
      'message':     @state.message
      'delivery_at': @state.deliveryTime
      'deep_link':   @state.link or @state.customLink
      'filter':      filter

    $.ajax
      type: 'POST'
      url: '/admin/notifications'
      data:
        notification: data
      dataType: 'json'
      success: (response) ->
        Turbolinks.visit(CPA.path('/notifications'))
      error: (xhr) =>
        Gritter.error_msg('Error', xhr.responseText)

  render: ->
    CPA.Base.showLoading = false
    <div>
      {@renderBtn()}
      <hr />
      <div className="row">
        <div className="col-md-4">
          <h2>Recipients</h2>
          <div>Send to everyone, or use segments to choose the right moment.</div>
          {@renderDeviceCount()}
        </div>
        <div className="col-md-8">
          {@renderLists('platform')}
          {@renderLists('country')}
        </div>
      </div>
      <hr />
      <div className="row">
        <div className="col-md-4">
          <h2>Delivery Time</h2>
          <div>We can send the campaign immediately, or wait until just the right moment.</div>
        </div>
        <div className="col-md-8">
          {@renderDelivery()}
        </div>
      </div>
      <hr />
      <div className="row">
        <div className="col-md-4">
          <h2>Message</h2>
          <div>The best campaigns use short and direct messaging.</div>
        </div>
        <div className="col-md-8">
          <h4>Your Message</h4>
          {@renderMessageInput()}
        </div>
      </div>
      <hr />
      <div className="row">
        <div className="col-md-4">
          <h2>Deeplink</h2>
          <div>The best campaigns use short and direct messaging.</div>
        </div>
        <div className="col-md-8">
          {@renderDeepLinks()}
        </div>
      </div>
      <hr />
      {@renderBtn()}
    </div>
