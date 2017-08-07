window.CmdpAdmin.AddFilterButton = React.createClass
  render: ->
    `<button className='btn btn-sm btn-primary' onClick={this.props.onClick}>
      <i className='fa fa-plus'></i>
    </button>`