# @cjsx

@CPA.Notification.DeeplinkInput = React.createClass

  getInitialState: ->
    custom: true

  render: ->
    if @props.readOnly
      <div>
        <h4>Target</h4>
        <div className="form-control read-only">{@props.value}</div>
      </div>
    else
      <div>
        <h4>Target</h4>
        <CPA.Base.SelectInput value={@props.value}
                              collection={@props.links}
                              onChange={@updateSelectLink} />
        {@renderCustomInput()}
      </div>

  renderCustomInput: ->
    if @state.custom
      <CPA.Base.TextInput className="form-control pull-left noti-input-fixed"
                          value=""
                          placeholder="Please input custom deep link."
                          onBlur={@updateCustomLink} />

  updateSelectLink: (e) ->
    @setState(custom: (e.target.value is ''))
    @props.onChange?(e)

  updateCustomLink: (e) ->
    @props.onChange?(e)