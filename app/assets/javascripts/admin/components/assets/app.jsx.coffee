#= require react-mini-router
# @cjsx

@CPA.Assets.App = React.createClass
  mixins: [ReactMiniRouter.RouterMixin]

  routes:
    '/': 'home'
    '/:id': 'show'
    '/:id/edit': 'edit'

  home:(qs) ->
    filters = if qs.q
                JSON.parse(qs.q)
              else
                [{ type: 'search', value: '' }]
    <CPA.Assets.Index filters={filters}/>

  show: (id) ->
    <CPA.Assets.Show id={parseInt(id)} />

  edit: (id) ->
    <CPA.Assets.Edit id={parseInt(id)} />

  render: ->
    @renderCurrentRoute()
