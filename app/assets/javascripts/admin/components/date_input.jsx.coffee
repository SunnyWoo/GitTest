# @cjsx

@CmdpAdmin.DateInput = React.createClass
  propTypes:
    value: React.PropTypes.string
    onChange: React.PropTypes.func.isRequired
  
  render: ->
    <input type="date" 
           className="rc-date-input" 
           value={@props.value}
           onChange={@props.onChange} />
