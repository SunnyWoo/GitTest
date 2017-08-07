# @cjsx

@CmdpAdmin.ReportUpdate = React.createClass
  propTypes:
    url: React.PropTypes.string
    
  update: ->
    url = @props.url

    ajax = $.ajax
      url: url
      type: 'PATCH'

    ajax.done (response) ->
      window.location.reload()

  render: ->
    <div className="report-update">
      <button className="btn btn-md btn-warning" onClick={@update}>
        Update Report
      </button>
    </div>