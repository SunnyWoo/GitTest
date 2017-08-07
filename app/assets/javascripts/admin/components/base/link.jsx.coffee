#= require react-mini-router
# @cjsx

@CPA.Base.Link = React.createClass
  processLink: (e) ->
    e.preventDefault()
    ReactMiniRouter.navigate(@props.href)

  render: ->
    props = _.merge({}, @props, href: '#!' + @props.href)
    <a {...props} onClick={@processLink} />
