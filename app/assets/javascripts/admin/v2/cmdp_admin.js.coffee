#= require react
#= require react_ujs
#= require fluxxor
#= require_self
#= require_tree ../clients
#= require_tree ../fluxxor_stores
#= require_tree ../fluxxor_actions
#= require jquery.tokeninput
#= require ./home_products
#= require ./work_templates
#= require ./header_links
#= require ./product_code
#= require ./purchase
#= require ./report
#= require ./product_model
#= require ./link_to_add_fields

@CmdpAdmin or=
  Stores: {}
  Actions: {}

  Clients: {}
  fluxxorStores: {}
  fluxxorStoreClasses: {}
  fluxxorActions: {}

  Base: {} # 只放 facebook flux 元件
  Common: {} # 只放 fluxxor 元件
  PriceTiers: {}
  Reports: {}
  Coupons: {}
  Unapproved: {}
  Assets: {}
  Notification: {}
  HomeBlocks: {}
  Jobs: {}
  Tags: {}
  StandardizedWorkEditor: {}

  FluxMixin: Fluxxor.FluxMixin(React)

  # 將路徑自動加上 /:locale/admin 的前綴以支援語系切換
  path: (path) ->
    if location.pathname.match(/.+\/admin/)
      location.pathname.match(/.+\/admin/)[0] + path
    else
      path

  getFlux: ->
    @flux or= new Fluxxor.Flux(@fluxxorStores, @fluxxorActions)

  createFlux: (storeNames, actionNames) ->
    stores = _.mapValues(_.pick(@fluxxorStoreClasses, storeNames...), (storeClass) -> new storeClass())
    actions = _.pick(@fluxxorActions, actionNames)
    new Fluxxor.Flux(stores, actions)

@CPA = @CmdpAdmin
