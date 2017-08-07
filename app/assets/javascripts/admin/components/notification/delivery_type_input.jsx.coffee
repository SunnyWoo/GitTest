# @cjsx

@CPA.Notification.DeliveryTypeInput = React.createClass

  render: ->
    <div className="form-inline">
      <h4>Delivery Type</h4>
      <div className="radio">
        <label>
          <input type="radio" name="time"
                 value="now" className="ace"
                 checked={@checkPushOption('now')}
                 onChange={@updateOption} />
          <span className="lbl">Now</span>
        </label>
      </div>
      <div className="radio">
        <label>
          <input type="radio" name="time"
                 value="later" className="ace"
                 checked={@checkPushOption('later')}
                 onChange={@updateOption} />
          <span className="lbl">Later</span>
        </label>
      </div>
    </div>

  checkPushOption: (type) -> @props.option is type

  updateOption: (e) ->
    @props.onChange?(e)
