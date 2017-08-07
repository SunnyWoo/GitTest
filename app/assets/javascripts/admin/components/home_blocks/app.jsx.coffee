#= require react-mini-router
# @cjsx

@CPA.HomeBlocks.App = React.createClass
  mixins: [ReactMiniRouter.RouterMixin, CPA.FluxMixin]

  getDefaultProps: ->
    flux: CPA.getFlux()

  routes:
    '/': 'home'

  home: ->
    <CPA.HomeBlocks.Index />

  render: ->
    @renderCurrentRoute()
