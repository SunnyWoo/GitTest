# @cjsx

@CPA.Jobs.Status = React.createClass
  mixins: [
    CPA.FluxMixin
    Fluxxor.StoreWatchMixin('JobStore')
  ]

  getDefaultProps: ->
    flux: CPA.getFlux()

  getStateFromFlux: ->
    job: @getFlux().store('JobStore').get(@props.id)

  componentDidMount: ->
    @getFlux().actions.startPollingJob(@props.id)

  render: ->
    switch @state.job.status
      when 'queued'
        <span className='badge badge-warning'><i className="fa fa-spinner fa-pulse"></i> Queued</span>
      when 'working'
        <span className='badge badge-warning'><i className="fa fa-spinner fa-pulse"></i> Working</span>
      when 'complete'
        <span className='badge badge-success'><i className="fa fa-check"></i> Complete</span>
      when 'failed'
        <span className='badge badge-danger'><i className="fa fa-exclamation-triangle"></i> Failed</span>
      else
        <div>WTF</div>

@CPA.Jobs.renderStatus = (domId, jobId) ->
  el = document.getElementById(domId).parentElement
  React.render(React.createElement(CPA.Jobs.Status, id: jobId), el)
  $(document).on 'page:receive', -> React.unmountComponentAtNode(el)
