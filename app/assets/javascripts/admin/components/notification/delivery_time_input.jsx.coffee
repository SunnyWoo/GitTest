# @cjsx

@CPA.Notification.DeliveryTimeInput = React.createClass
  
  getInitialState: ->
    date: @props.value
    hour: '00'
    minute: '00'

  render: ->
    <div>
      <h4>Delivery on</h4>
      <CPA.Base.DateInput value={@state.date} onChange={@updateDate} />
      <span className="padding-right"> </span>
      <CPA.Base.SelectInput value={@state.hour}
                            collection={@renderCollection(24)}
                            onChange={@updateHour} />
      <span>:</span>
      <CPA.Base.SelectInput value={@state.minute}
                            collection={@renderCollection(60)}
                            onChange={@updateMinute} />
    </div>

  updateDate: (e) ->
    @setState(date: e.target.value)
    dateTime = e.target.value + ' ' + @state.hour + ':' + @state.minute
    @props.onChange?(dateTime)

  updateHour: (e) ->
    @setState(hour: e.target.value)
    dateTime = @state.date + ' ' + e.target.value + ':' + @state.minute
    @props.onChange?(dateTime)

  updateMinute: (e) ->
    @setState(minute: e.target.value)
    dateTime = @state.date + ' ' + @state.hour + ':' + e.target.value
    @props.onChange?(dateTime)

  renderCollection: (max) ->
    collection = []
    for i in [0...max]
      str = i.toString()
      if str.length >= 2
        collection.push({value: str, label: str})
      else
        collection.push({value: '0'+str, label: '0'+str})
    collection