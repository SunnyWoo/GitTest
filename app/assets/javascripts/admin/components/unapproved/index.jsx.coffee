#= require react-mini-router

# @cjsx

@CPA.Unapproved.Index = React.createClass
  mixins: [
    ReactMiniRouter.RouterMixin
  ]

  routes: 
    '/':                 'standard'
    '/standard':         'standard'
    '/express':          'express'

  render: -> @renderCurrentRoute()

  standard: ->
    filters = [{ type: 'shipping_info_shipping_way_in', value: '0,2' }]
    <div key="standard">
      <CPA.Unapproved.App type="standard" 
                          filters={filters}
                          url={@props.apiUrl}
                          countUrl={@props.itemCountUrl} />
    </div>

  express: ->
    filters = [{ type: 'shipping_info_shipping_way_in', value: '1' }]
    <div key="express">
      <CPA.Unapproved.App type="express" 
                          filters={filters}
                          url={@props.apiUrl}
                          countUrl={@props.itemCountUrl} />
    </div>